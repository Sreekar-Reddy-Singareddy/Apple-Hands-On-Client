/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package services;

import beans.Exam;
import beans.Trainee;
import com.google.gson.Gson;

import java.sql.*;
import java.text.SimpleDateFormat;

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
    public String loginTrainee (String traineeJson) throws SQLException {
        System.out.println("Inside loginTrainee method");
        Gson gson = HandsOnUtils.getGson();
        Trainee trainee = (Trainee) gson.fromJson(traineeJson, Trainee.class);
        Exam exam = (Exam) gson.fromJson(traineeJson, Exam.class);
        System.out.println("Trainee ID: "+trainee.getEmpId());
        System.out.println("Exam Code : "+exam.getExamCode());

        conn = HandsOnUtils.getMySQLConnection();
        PreparedStatement statement = null;
        ResultSet resultSet = null;

        // Check if the trainee exists or not
        statement = conn.prepareStatement("SELECT EMP_ID FROM TRAINEES_DATA WHERE EMP_ID = ?");
        statement.setLong(1, trainee.getEmpId());
        resultSet = statement.executeQuery();
        if (!resultSet.next()) { return "NO_TRAINEE"; }

        // Check if the trainee has already logged in
        statement = conn.prepareStatement("SELECT EMP_ID FROM EXAM_STATUS WHERE EMP_ID = ? AND EXAM_CODE = ?");
        statement.setLong(1, trainee.getEmpId());
        statement.setLong(2, exam.getExamCode());
        resultSet = statement.executeQuery();
        boolean existsFlag = resultSet.next();
        if (existsFlag) {
            // Check if the trainee has already finished the assessment
            // Assessment could be finished in 2 ways
            // 1. Submitted before 3 hours elapsed
            // 2. Three hours have elapsed whether submitted or not
            statement = conn.prepareStatement("SELECT EMP_ID FROM EXAM_STATUS WHERE EMP_ID = ? AND EXAM_CODE = ? AND ENDS_AT >= NOW() AND SUBMITTED = 0");
            statement.setLong(1, trainee.getEmpId());
            statement.setLong(2, exam.getExamCode());
            resultSet = statement.executeQuery();
            if (!resultSet.next()) { return  "EXAM_FINISHED";}
        }

        // If trainee exists, then check for the exam code, date and time
        statement = conn.prepareStatement("SELECT EXAM_CODE FROM EXAM_DATA WHERE EXAM_CODE = ? " +
                "AND DATE(EXAM_DATE) = DATE(NOW()) AND TIME(NOW()) >= TIME(START_TIME) AND TIME(NOW()) <= TIME(END_TIME)");
        statement.setLong(1, exam.getExamCode());
        resultSet = statement.executeQuery();
        boolean newFlag = resultSet.next();
        if (newFlag && existsFlag) { return "RESUME_EXAM";}
        else if (newFlag) { return "VALID";}

        return "NO_EXAM_TODAY";
    }
    
}
