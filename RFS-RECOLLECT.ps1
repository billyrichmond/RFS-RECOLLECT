#RFS-RECOLLECT.ps1
 $code = @"
 
    using System;
     using System.Collections;
     using System.Collections.Specialized;
     using System.IO;
     
     public class Application
     {
         public bool auditMode = true;
         public string COLLECTOR;
         public string logDate = DateTime.Now.ToString("yyyy-MM-dd-HH-mm-ss");
         public ArrayList arrayListPaths = new ArrayList();
         
         public void DoWork(string _collectorDirectory, string _collectorName, bool _auditMode)
         {
             auditMode = _auditMode;
             COLLECTOR = _collectorName;
             
             try
             {
                 DirectoryInfo collectorDirectory = new DirectoryInfo(Path.Combine(_collectorDirectory, _collectorName));
                 if (collectorDirectory.Exists)
                 {
                     SearchFiles(collectorDirectory.FullName);
                     SearchDirectories(collectorDirectory.FullName);
                     Console.ForegroundColor = ConsoleColor.Green;
                     Console.WriteLine("The log file can be found in the following directory: {0}", Directory.GetCurrentDirectory());
                     ResetConsoleColor();
                 }
             }
             catch(Exception ex)
             {
                 Console.ForegroundColor = ConsoleColor.Red;
                 Console.WriteLine(ex.Message);
                 ResetConsoleColor();
             }
         }
         
         public void SearchFiles(string _collectorDirectory)
         {
             try
             {
                 foreach(string fileName in Directory.GetFiles(_collectorDirectory))
                 {
                     IsRfsSecurityDescriptorFile(fileName);
                     IsRfsUserFile(fileName);
                 }
             }
             catch(Exception ex)
             {
                 Console.ForegroundColor = ConsoleColor.Red;
                 Console.WriteLine(ex.Message);
                 ResetConsoleColor();
             }
         }
         
         public void SearchDirectories(string _collectorDirectory)
         {
             try
             {
                 foreach(string directoryName in Directory.GetDirectories(_collectorDirectory))
                 {
                     arrayListPaths.Add(String.Format("{0}\t{1}\t{2}\t{3}", "Directory", _collectorDirectory, "Do nothing", "No change"));
                     Console.WriteLine(String.Format("{0}\t{1}\t{2}\t{3}", "Directory", _collectorDirectory, "Do nothing", "No change"));
                     UpdateLog(String.Format("{0}\t{1}\t{2}\t{3}", "Directory", _collectorDirectory, "Do nothing", "No change"));
                     SearchFiles(directoryName);
                     SearchDirectories(directoryName);
                 }
             }
             catch(Exception ex)
             {
                 Console.ForegroundColor = ConsoleColor.Red;
                 Console.WriteLine(ex.Message);
                 ResetConsoleColor();
             }
         }
         
         public void IsRfsSecurityDescriptorFile(string _fileName)
         {
             try
             {
                 FileInfo collectedFile = new FileInfo(_fileName);
                 if ( (collectedFile.Name.ToString().StartsWith("$$$RFS$$$")) && (Path.GetFileNameWithoutExtension(collectedFile.Name).Length == 9) )
                 {
                     if (auditMode == false)
                     {
                         collectedFile.Delete();
                     }
                     arrayListPaths.Add(String.Format("{0}\t{1}\t{2}\t{3}", "Security File", collectedFile.FullName, "Delete", "-"));
                     Console.WriteLine(String.Format("{0}\t{1}\t{2}\t{3}", "Security File", collectedFile.FullName, "Delete", "-"));
                     UpdateLog(String.Format("{0}\t{1}\t{2}\t{3}", "Security File", collectedFile.FullName, "Delete", "-"));
                 }
             }
             catch(Exception ex)
             {
                 Console.ForegroundColor = ConsoleColor.Red;
                 Console.WriteLine("Module: {0} Error: {1}", "IsRfsTripleDollarFile", ex.Message);
                 ResetConsoleColor();
             }
         }
         
         public void IsRfsUserFile(string _fileName)
         {
             try
             {
                 FileInfo collectedFile = new FileInfo(_fileName);
                 if ( (collectedFile.Name.ToString().StartsWith("$$$RFS$$$")) && (Path.GetFileNameWithoutExtension(collectedFile.Name).Length == 9) )
                 {
                     //Do nothing.  This is a Security Descriptor file.
                 }
                 else
                 {
                     string fileExtension = Path.GetExtension(collectedFile.Name);
                     bool startsWithDot = fileExtension.StartsWith(".");
                     if(startsWithDot)
                     {
                         string updatedFileExtension = fileExtension.Substring(1, fileExtension.Length - 1);
                         long numericExtension;
                         bool isNumber = Int64.TryParse(updatedFileExtension, out numericExtension);
                         if ( (isNumber) && (numericExtension > 0) )
                         {
                             if (auditMode == false)
                             {
                                 File.Move(collectedFile.FullName, Path.Combine(collectedFile.DirectoryName, Path.GetFileNameWithoutExtension(collectedFile.Name)));
                             }
                             arrayListPaths.Add(String.Format("{0}\t{1}\t{2}\t{3}", "User File", collectedFile.FullName, "Rename", Path.GetFileNameWithoutExtension(collectedFile.Name)));
                             Console.WriteLine(String.Format("{0}\t{1}\t{2}\t{3}", "User File", collectedFile.FullName, "Rename", Path.GetFileNameWithoutExtension(collectedFile.Name)));
                             UpdateLog(String.Format("{0}\t{1}\t{2}\t{3}", "User File", collectedFile.FullName, "Rename", Path.GetFileNameWithoutExtension(collectedFile.Name)));
                         }
                         else
                         {
                             arrayListPaths.Add(String.Format("{0}\t{1}\t{2}\t{3}", "User File", collectedFile.FullName, "Do nothing", "No change"));
                             Console.WriteLine(String.Format("{0}\t{1}\t{2}\t{3}", "User File", collectedFile.FullName, "Do nothing", "No change"));
                             UpdateLog(String.Format("{0}\t{1}\t{2}\t{3}", "User File", collectedFile.FullName, "Do nothing", "No change"));
                         }
                     }
                 }    
             }
             catch(Exception ex)
             {
                 Console.ForegroundColor = ConsoleColor.Red;
                 Console.WriteLine("Module: {0} Error: {1}", "IsRfsUserFile", ex.Message);
                 ResetConsoleColor();
             }
         }
         
         public void UpdateLog(string _message)
         {
             try
             {
                 if (auditMode)
                 {
                     FileInfo logFile = new FileInfo(Path.Combine(Directory.GetCurrentDirectory(), "RECOLLECT-" + COLLECTOR + "-AUDIT-(" + logDate + ").txt"));
                     using (StreamWriter logWriter = logFile.AppendText())
                     {
                         logWriter.WriteLine(_message);
                     }    
                 }
                 else
                 {
                     FileInfo logFile = new FileInfo(Path.Combine(Directory.GetCurrentDirectory(), "RECOLLECT-" + COLLECTOR + " (" + logDate + ").txt"));
                     using (StreamWriter logWriter = logFile.AppendText())
                     {
                         logWriter.WriteLine(_message);
                     }
                 }
             }
             catch(Exception ex)
             {
                 Console.ForegroundColor = ConsoleColor.Red;
                 Console.WriteLine("Module: {0} Error: {1}", "UpdateLog", ex.Message);
                 ResetConsoleColor();
             }
         }
         
         public void ResetConsoleColor()
         {
             Console.ForegroundColor = ConsoleColor.White;
         }
     }
 "@
 Clear-Host;
 Add-Type -TypeDefinition $code;
 $app = New-Object Application;
 $auditMode = $true;
 $collectorDirectory = "\\localhost\E$\collectors";
 $collectorName = "C_CSCB120120530191750(C).CSCB-ARCHIVE-2.WISTAR.UPENN.EDU";
 $app.DoWork($collectorDirectory, $collectorName, $auditMode);