/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package utilities;

import com.google.gson.Gson;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author bros
 */
public class HandsOnUtils {
    
    private static Gson GSON_GLOBAL;
    /**
     * This is a singleton connection object which will be created only once
     * through out the application and this can be accessed by calling getMySQLConnection()
     * from any where in the application.
     */
    private static Connection CONN;
    
    // Service flag strings
    public static String LOGIN_SERVICE_FLAG = "login";
    public static String REGISTER_SERVICE_FLAG = "register";
    public static String EXAM_SERVICE_FLAG = "exammode";
    public static String GET_TRAINEE_FLAG = "trainee";
    public static String SUBMIT_FILE_FLAG = "submit";
    
    // Response code strings
    public static String VALID = "VALID";
    public static String INVALID = "INVALID";
    
    // File related variables
    public static String BASE_PATH = "/Users/bros/Desktop/";
    public static String TRAINEES_LIST_PATH = "trainees.txt";
    public static String QPR_FILE = "QPR";
    public static String INS_FILE = "INS";
    public static String SUP_FILE = "SUP";
    
    // MySQL credentials
    private static String MYSQL_DRIVER = "com.mysql.cj.jdbc.Driver";
    private static String MYSQL_HOST = "127.0.0.1:3306";
    private static String MYSQL_USER = "sreekar";
    private static String MYSQL_PASS = "sreekar2019";
    private static String MYSQL_DB_NAME = "sreekar_db";
    private static String MYSQL_BASE_PATH = "jdbc:mysql://" + MYSQL_HOST + "/" + MYSQL_DB_NAME;
    
    static {
        // Creates only one GSON object
        GSON_GLOBAL = new Gson();
    }
    
    static {
        // Creates only one connection object 
        try {
            Class.forName(MYSQL_DRIVER);
            CONN = DriverManager.getConnection(MYSQL_BASE_PATH, MYSQL_USER, MYSQL_PASS);
            System.out.println("Connection MySQL: "+CONN);
        } catch (ClassNotFoundException ex) { // TODO: Handle the exceptions well
            System.out.println("Class not found: "+ex.getLocalizedMessage());
        } catch (SQLException ex) {
            System.out.println("SQL Exception: "+ex.getLocalizedMessage());
        }
    }
    
    /**
     * returns the global GSON object to the caller
     * @return 
     */
    public static Gson getGson() {
        return GSON_GLOBAL;
    }
    
    /**
     * returns the singleton connection object to the caller
     * @return 
     */
    public static Connection getMySQLConnection () {
        return CONN;
    }
    
}
