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
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import javax.servlet.http.HttpServletResponse;
import utilities.HandsOnUtils;

/**
 *
 * @author bros
 */
public class Exammode {
    
    private Connection conn = HandsOnUtils.getMySQLConnection();
    
    /**
     * This method takes the type of file that needs to be downloaded
     * and returns some code in case of any failure in download process
     * @param
     * @param trainee
     * @return
     */
    public String downloadFile(Trainee trainee, Exam exam, HttpServletResponse mainResp) throws SQLException, IOException { // TODO: Did you handle these exceptions propertly
        System.out.println("Inside downloadFile with examcode: "+exam.getExamCode());
        PreparedStatement statement = null;
        if (exam.getFileType().toUpperCase().equals(HandsOnUtils.INS_FILE)) {
            // Downloads the instructions pdf file from database
            statement = conn.prepareStatement("SELECT NAME FROM FILE_DATA WHERE FILE_ID = (SELECT INSTRUCTIONS FROM EXAM_DATA WHERE EXAM_CODE = ?)");
        }
        else if (exam.getFileType().toUpperCase().equals(HandsOnUtils.QPR_FILE)) {
            boolean flag = false;
            PreparedStatement checkTraineeQuery = conn.prepareStatement("SELECT * FROM EXAM_STATUS WHERE EMP_ID = ? AND EXAM_CODE = ?");
            checkTraineeQuery.setLong(1, trainee.getEmpId());
            checkTraineeQuery.setLong(2, exam.getExamCode());
            ResultSet resultSet = checkTraineeQuery.executeQuery();
            flag = resultSet.next(); // Will be true only if the result set has atleast one row, else false
            // When the trainee has already logged in, do not try this insert statement
            // Simply skip the insertion logic and proceed with the file download
            // This code will execute only once
            if (!flag) {
                PreparedStatement insertData = conn.prepareStatement("INSERT INTO EXAM_STATUS (EMP_ID, STARTED_AT, ENDS_AT, EXAM_DATE, EXAM_CODE) " +
                        "VALUES (?, NOW(), ADDTIME(NOW(), \"3:00:00\"), NOW(), ?)");
                insertData.setLong(1, trainee.getEmpId());
                insertData.setLong(2, exam.getExamCode());
                int rowsAffected = insertData.executeUpdate();
                if (rowsAffected == 1) {
                    // This means that the current trainee's exam data is inserted
                    // TODO: As of now nothing, but perform logic here in future
                }
            }

            // Downloads the question paper pdf file from database
            statement = conn.prepareStatement("SELECT NAME FROM FILE_DATA WHERE FILE_ID = (SELECT QUESTION FROM EXAM_DATA WHERE EXAM_CODE = ?)");
        }
        else if (exam.getFileType().toUpperCase().equals(HandsOnUtils.SUP_FILE)) {
            // Downloads the supplied files zip from database
            statement = conn.prepareStatement("SELECT NAME FROM FILE_DATA WHERE FILE_ID = (SELECT SUPPLIED FROM EXAM_DATA WHERE EXAM_CODE = ?)");
        }

        // Passing the parameters
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
        PreparedStatement statement = conn.prepareStatement("SELECT NAME FROM TRAINEES_DATA WHERE EMP_ID = ?");
        statement.setLong(1, trainee.getEmpId());
        ResultSet result = statement.executeQuery();
        result.next();
        String traineeName = result.getString("NAME");
        return traineeName;
    }

    /**
     * This method takes EMP ID, EXAM CODE and using these details
     * it fetches the END TIME & START TIME of the trainee
     * @return Dictonary of two key value pairs as stated above
     */
    public HashMap<String, Object> fetchTimerDetails (String examJson) {
        System.out.println("Inside fetchTimerDetails method");
        Gson gson = HandsOnUtils.getGson();
        Exam exam = gson.fromJson(examJson, Exam.class);
        Trainee trainee = gson.fromJson(examJson, Trainee.class);
        // Hash Map to pass on details to the Xcode end
        HashMap <String, Object> timerTrainee = new HashMap<>();
        // SQL Logic
        try {
            PreparedStatement statement = conn.prepareStatement("SELECT STARTED_AT, ENDS_AT, NOW() TIME_STAMP FROM EXAM_STATUS WHERE EMP_ID = ? AND EXAM_CODE = ?");
            statement.setLong(1, trainee.getEmpId());
            statement.setLong(2, exam.getExamCode());
            ResultSet resultSet = statement.executeQuery();
            while (resultSet.next() ) {
                // Using these details, create key-value pairs in the hash map
                timerTrainee.put("empId", trainee.getEmpId());
                timerTrainee.put("examCode", exam.getExamCode());
                timerTrainee.put("startedAt", resultSet.getObject("STARTED_AT"));
                timerTrainee.put("endsAt", resultSet.getObject("ENDS_AT"));
                timerTrainee.put("timeStamp", resultSet.getObject("TIME_STAMP"));
                System.out.println("Timer Details: "+timerTrainee);
                return timerTrainee;
            }
            return null;
        } catch (SQLException e) {
            System.out.println("SQL Error occured while refreshing timer");
            return null;
        }
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
