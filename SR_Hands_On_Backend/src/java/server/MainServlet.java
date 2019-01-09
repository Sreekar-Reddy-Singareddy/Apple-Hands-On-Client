/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package server;

import beans.Exam;
import beans.Trainee;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import services.Exammode;
import services.Login;
import services.Register;
import utilities.HandsOnUtils;

/**
 *
 * @author sreekar.singareddy
 */
public class MainServlet extends HttpServlet {
    
    private String serviceFlag;
    private PrintWriter responseWriter;

    
    // Every incoming request calls either of these two methods
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        System.out.println("Inside GET SR_Hands_On");
        doPost(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException{ // TODO: Handle all the exceptions here
        System.out.println("Inside POST SR_Hands_On");
        try {
            scanRequest(req, resp);
        }
        catch (IOException ex) {
            System.out.println("Exception IO: "+ex.getLocalizedMessage());
        } catch (SQLException ex) {
            System.out.println("SQL Error occured: "+ex.getLocalizedMessage()); // TODO: Handle the exceptions well
            responseWriter.write("DATABASE_ERROR");
        }
    }
    
    /**
     * This method decides where the request will be redirected to
     * @param req - received request
     * @param res - response about to be sent
     */
    private void scanRequest (HttpServletRequest req, HttpServletResponse res) throws IOException, SQLException {
        System.out.println("Inside scanRequest method");
        serviceFlag = req.getPathInfo().substring(1);
        // Start 'Login' service
        if (serviceFlag.toLowerCase().equals(HandsOnUtils.LOGIN_SERVICE_FLAG)) {
            responseWriter = res.getWriter();
            Login login = new Login();
            boolean loginIsValid = login.loginTrainee(parseDataStream(req.getInputStream()));
            if (loginIsValid) {
                responseWriter.write(HandsOnUtils.VALID);
            }
            else {
                responseWriter.write(HandsOnUtils.INVALID);
            }
            responseWriter.close();
        }
        // Start 'Register' service
        else if (serviceFlag.toLowerCase().equals(HandsOnUtils.REGISTER_SERVICE_FLAG)) {
            responseWriter = res.getWriter();
            Register regiser = new Register();
            String result = regiser.registerTrainee(parseDataStream(req.getInputStream()));
            responseWriter.write(result);
            responseWriter.close();
            System.out.println("Register Result: "+result);
        }
        // Start 'Exam mode' service
        else if (serviceFlag.toLowerCase().equals(HandsOnUtils.EXAM_SERVICE_FLAG)) {
            // Create exam bean
            Exammode exammode = new Exammode();
            Exam exam = exammode.createExamBean(parseDataStream(req.getInputStream()));
            
            // Download the file
            String result = exammode.downloadFile(exam, res); // TODO: Get these values from the request
            if (result.equals("SUCCESS")) {
                // TODO: Maybe you can do something here
                return;
            }
            else {
                responseWriter = res.getWriter();
                responseWriter.write(result);
                responseWriter.close();
            }
        }
        // Fetches the trainee with given employee ID
        else if (serviceFlag.toLowerCase().equals(HandsOnUtils.GET_TRAINEE_FLAG)) {
            // Create exam bean // TODO: Can we have seperate service for this alone?
            Exammode exammode = new Exammode();
            String traineeName = exammode.getTrainee(parseDataStream(req.getInputStream()));
            System.out.println("Trainee Name: "+traineeName);
            responseWriter = res.getWriter();
            responseWriter.write("Name:"+traineeName);
            responseWriter.close();
        }
    }
    
    private String parseDataStream (InputStream reqStream) {
        StringBuilder convertedData = new StringBuilder("");
        try {
            // Converts the data into string
            int dataCapacity = 256;
            int len = -1;
            byte[] data = new byte[dataCapacity];
            while ((len = reqStream.read(data, 0, dataCapacity)) != -1) {
                String temp = new String(data, 0, len);
                convertedData.append(temp);
            }
        } catch (IOException ex) {
            System.out.println("Error in parsing the data");
        }
        return convertedData.toString();
    }
}
