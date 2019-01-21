/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package services;

import beans.Trainee;
import com.google.gson.Gson;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import utilities.HandsOnUtils;

/**
 *
 * @author bros
 */
public class Register {
    
    private static ArrayList<Long> TRAINEES;
    private Connection conn;
    
    // Loads the valid list of trainees into a static array from an external file
    static {
        TRAINEES = new ArrayList<>();
        try {
            File traineesFile = new File(HandsOnUtils.BASE_PATH+HandsOnUtils.TRAINEES_LIST_PATH);
            FileReader fReader = new FileReader(traineesFile);
            BufferedReader bReader = new BufferedReader(fReader);
            String empId = "";
            while ((empId = bReader.readLine()) != null) {
                Long id = Long.parseLong(empId);
                TRAINEES.add(id);
            }
            System.out.println("Trainees List: "+TRAINEES);
        } 
        catch (FileNotFoundException ex) { // TODO: Handle these exceptions properly
            System.out.println("Trainees file was not found: "+ex.getLocalizedMessage());
        } 
        catch (IOException ex) {
            System.out.println("IO Exception occured: "+ex.getLocalizedMessage());
        }
        catch (NumberFormatException ex) {
            System.out.println("Number is not in valid format: "+ex.getLocalizedMessage());
        }
    }
    
    /**
     * Registers the given trainee details in the database conditionally
     * @param traineeJson
     * @return 
     */
    public String registerTrainee (String traineeJson) throws SQLException { // TODO: Store all these string codes somewhere
        System.out.println("Inside registerTrainee method");
        Gson gson = HandsOnUtils.getGson();
        Trainee trainee = (Trainee) gson.fromJson(traineeJson, Trainee.class);
        System.out.println("Trainee Exists: "+trainee.getFirstName());
        
        // Validate the details of the trainee
        if (!isValidId(trainee.getEmpId())) {
            return "INVALID_EMPID";
        }
        if (!isValidName(trainee.getFirstName()) || !isValidName(trainee.getLastName())) {
            return "INVALID_NAME";
        }
        if (!isValidMail(trainee.getEmailId())) {
            return "INVALID_EMAIL";
        }
         
        // Get DB Connection
        conn = HandsOnUtils.getMySQLConnection();
        PreparedStatement statement = conn.prepareStatement("SELECT EMP_ID FROM TRAINEES_DATA WHERE EMP_ID = ?");
        statement.setLong(1, trainee.getEmpId());
        ResultSet result = statement.executeQuery();
        while (result.next()) {
            // There is atleast on row
            return "TRAINEE_EXISTS"; // TODO: This is false because trainee already exists
        }
        
        statement = conn.prepareStatement("INSERT INTO TRAINEES_DATA VALUES (?, ?, ?, ?, ?)");
        statement.setLong(1, trainee.getEmpId());
        statement.setString(2, trainee.getIp_address());
        statement.setString(3, trainee.getFirstName().toLowerCase() + " " + trainee.getLastName().toLowerCase());
        statement.setString(4, trainee.getEmailId());
        statement.setString(5, trainee.getBatchCode());
        int rowsAffected = statement.executeUpdate();
        if (rowsAffected == 1) {
            // Trainee registered successfully
            return "SUCCESS";
        }
        return "DATABASE_ERROR";
    }
    
    private boolean isValidId (Long empId) { // TODO; May be we can use custom exceptions here
        return TRAINEES.contains(empId);
    }
    
    private boolean isValidName (String name) { // TODO; May be we can use custom exceptions here
        // TODO: Validate the name
        if (name.matches("([A-Za-z ])+")) {
            return true;
        }
        return false;
    }
    
    private boolean isValidMail (String mail) { // TODO; May be we can use custom exceptions here
        // TODO: Validate the mail
        if (mail.matches("([A-Za-z0-9_\\.])+(@){1}(infosys.com){1}")) {
            return true;
        }
        return false;
    }
    
}
