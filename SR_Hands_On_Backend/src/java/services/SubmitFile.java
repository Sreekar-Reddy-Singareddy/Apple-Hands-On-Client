/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package services;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import utilities.HandsOnUtils;

/**
 *
 * @author bros
 */
public class SubmitFile {
    
    private Connection conn = HandsOnUtils.getMySQLConnection();
    
    
    public boolean submitFile (String fileName, InputStream fileData){
        try {
            File file = new File(HandsOnUtils.BASE_PATH + "SR_Submissions/" + fileName);
            System.out.println("Exists: "+file.exists());
            System.out.println("Created: "+file.createNewFile());
            FileOutputStream oStream = new FileOutputStream(file);
            int dataCapacity = 1024;
            int len = -1;
            long downloaded = 0l;
            byte[] data = new byte[dataCapacity];
            while ((len = fileData.read(data, 0, dataCapacity)) != -1) {
                System.out.println("Data Downloading... "+downloaded);
                oStream.write(data, 0, len);
                downloaded += 1;
            }
            oStream.close();
            return true;
        }
        catch (IOException ex) {
            System.out.println("Some exception occured in downloading the file");
            return false;
        }
    }
    
}
