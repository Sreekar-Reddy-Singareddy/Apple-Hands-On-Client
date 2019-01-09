/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package services;

import beans.Exam;
import beans.Trainee;
import com.google.gson.Gson;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import utilities.HandsOnUtils;

/**
 *
 * @author bros
 */
public class Login {
    
    private Connection conn;

    /**
     * Gets the trainee's details and verify them.
     * Returns true if valid trainee, else false.
     */
    public boolean loginTrainee (String traineeJson) throws SQLException {
        System.out.println("Inside loginTrainee method");
        Gson gson = HandsOnUtils.getGson();
        Trainee trainee = (Trainee) gson.fromJson(traineeJson, Trainee.class);
        Exam exam = (Exam) gson.fromJson(traineeJson, Exam.class);
        System.out.println("Trainee ID: "+trainee.getEmpId());
        System.out.println("Exam Code : "+exam.getExamCode());
        
        conn = HandsOnUtils.getMySQLConnection();
        PreparedStatement statement = conn.prepareStatement("SELECT EXAM_CODE FROM EXAM_DATA WHERE EXAM_CODE = ? AND EXISTS (SELECT EMP_ID FROM TRAINEES_DATA WHERE EMP_ID = ?)");
        statement.setLong(1, exam.getExamCode());
        statement.setLong(2, trainee.getEmpId());
        ResultSet result = statement.executeQuery();
        while (result.next()) {
            // Trainee exists if control comes inside this block
            return true;
        }
        return false;
    }
    
}
