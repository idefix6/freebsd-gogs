--- src/gopkg.in/ini.v1/ini.go.orig	2015-12-11 21:51:11 UTC
+++ src/gopkg.in/ini.v1/ini.go
@@ -1000,12 +1000,7 @@ func (f *File) WriteTo(w io.Writer) (int
 
 // SaveToIndent writes content to file system with given value indention.
 func (f *File) SaveToIndent(filename, indent string) error {
-	// Note: Because we are truncating with os.Create,
-	// 	so it's safer to save to a temporary file location and rename afte done.
-	tmpPath := filename + "." + strconv.Itoa(time.Now().Nanosecond()) + ".tmp"
-	defer os.Remove(tmpPath)
-
-	fw, err := os.Create(tmpPath)
+	fw, err := os.Create(filename)
 	if err != nil {
 		return err
 	}
@@ -1014,11 +1009,7 @@ func (f *File) SaveToIndent(filename, in
 		fw.Close()
 		return err
 	}
-	fw.Close()
-
-	// Remove old file and rename the new one.
-	os.Remove(filename)
-	return os.Rename(tmpPath, filename)
+	return fw.Close()
 }
 
 // SaveTo writes content to file system.
