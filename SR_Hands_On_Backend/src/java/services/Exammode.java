/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package services;

import beans.Exam;
import beans.Trainee;
import com.google.gson.Gson;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.servlet.http.HttpServletResponse;
import utilities.HandsOnUtils;

/**
 *
 * @author bros
 */
public class Exammode {
    
    private Connection conn;
    
    /**
     * This method take the exam details from JSON
     * and creates exam bean out of it
     * @param jsonExam
     * @return - Exam bean object
     */
    public Exam createExamBean (String jsonExam) {
        Gson gson = HandsOnUtils.getGson();
        Exam exam = gson.fromJson(jsonExam, Exam.class);
        return exam;
    }
    
    /**
     * This method takes the type of file that needs to be downloaded
     * and returns some code
     * @param typeOfFile
     * @return 
     */
    public String downloadFile (Exam exam, HttpServletResponse mainResp) throws SQLException, IOException { // TODO: Did you handle these exceptions propertly
        System.out.println("Inside downloadFile with examcode: "+exam.getExamCode());
        conn = HandsOnUtils.getMySQLConnection();
        PreparedStatement statement = null;
        if (exam.getFileType().toUpperCase().equals(HandsOnUtils.INS_FILE)) {
            // Downloads the instructions pdf file from database
            statement = conn.prepareStatement("SELECT NAME FROM FILE_DATA WHERE FILE_ID = (SELECT INSTRUCTIONS FROM EXAM_DATA WHERE EXAM_CODE = ?)");
        }
        else if (exam.getFileType().toUpperCase().equals(HandsOnUtils.QPR_FILE)) {
            // Downloads the question paper pdf file from database
            statement = conn.prepareStatement("SELECT NAME FROM FILE_DATA WHERE FILE_ID = (SELECT QUESTION FROM EXAM_DATA WHERE EXAM_CODE = ?)");
        }
        else if (exam.getFileType().toUpperCase().equals(HandsOnUtils.SUP_FILE)) {
            // Downloads the supplied files zip from database
            statement = conn.prepareStatement("SELECT NAME FROM FILE_DATA WHERE FILE_ID = (SELECT SUPPLIED FROM EXAM_DATA WHERE EXAM_CODE = ?)");
        }
        statement.setLong(1, exam.getExamCode());
        ResultSet result = statement.executeQuery();
        if (!result.next()) {
            return "INVALID_EXAMCODE";
        }
        // Only if the exam code is valid, do we get the file
        String downloadableFileName = result.getString("NAME"); // This string value is case sensitive everywhere
        System.out.println("File Name: "+ downloadableFileName);
        
        // Check if this file is a valid one
        if (downloadableFileName.equals("no_file")) {
            return "NO_SUPPLIED_FILES";
        }
        
        // Use this file name and download it
        File file = new File(HandsOnUtils.BASE_PATH + "/" + downloadableFileName);
        System.out.println("File exists: "+file.exists());
        convertFiletoData(file, mainResp);
        return "SUCCESS";
    }
    
    public String getTrainee(String jsonTrainee) throws SQLException {
        System.out.println("Inside getTrainee method: "+jsonTrainee);
        Gson gson = HandsOnUtils.getGson();
        Trainee trainee = gson.fromJson(jsonTrainee, Trainee.class);
        System.out.println("Trainee EMPID::: "+trainee.getEmpId());
        conn = HandsOnUtils.getMySQLConnection();
        PreparedStatement statement = conn.prepareStatement("SELECT NAME FROM TRAINEES_DATA WHERE EMP_ID = ?");
        statement.setLong(1, trainee.getEmpId());
        ResultSet result = statement.executeQuery();
        result.next();
        String traineeName = result.getString("NAME");
        return traineeName;
    }
    
    private void convertFiletoData (File file, HttpServletResponse mainResponse) throws FileNotFoundException, IOException { // TODO: IS this exception handled finally?
        System.out.println("Inside convertFiletoData");
        int downloadSize = 1024;
        byte[] partialData = new byte[downloadSize];
        int dataLen = 0; int down = 0;
        OutputStream oStream = mainResponse.getOutputStream(); 
        FileInputStream iStream = new FileInputStream(file);
        while ((dataLen = iStream.read(partialData, 0, downloadSize)) != -1) {
            // Copy the converted data into main response's output stream
            oStream.write(partialData, 0, dataLen);
            System.out.println(down += dataLen);
        }
        // Once done, close the stream
        oStream.close();
    }
}
