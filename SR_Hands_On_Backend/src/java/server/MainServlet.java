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
import java.util.HashMap;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import com.google.gson.Gson;
import services.Exammode;
import services.Login;
import services.Register;
import services.SubmitFile;
import utilities.HandsOnUtils;

/**
 *
 * @author sreekar.singareddy
 */
public class MainServlet extends HttpServlet {
    
    private String serviceFlag;
    private PrintWriter responseWriter;
    private Gson gson = HandsOnUtils.getGson();

    
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
        String [] urlParts = req.getPathInfo().split("/");
        serviceFlag = urlParts[1];
        HandsOnUtils hn = new HandsOnUtils();
        System.out.println("Flag: "+serviceFlag);
        System.out.println("Flag: "+serviceFlag.equals(HandsOnUtils.UPDATE_SUBMISSION_FLAG));

        // Checks the connection to the client
        if (serviceFlag.toLowerCase().equals(HandsOnUtils.TEST_CONN_FLAG)) {
            System.out.println("Testing Connection!");
            responseWriter = res.getWriter();
            responseWriter.write("TEST_OK");
            responseWriter.close();
        }
        // Start 'Login' service
        else if (serviceFlag.toLowerCase().equals(HandsOnUtils.LOGIN_SERVICE_FLAG)) {
            responseWriter = res.getWriter();
            Login login = new Login();
            String loginResultCode = login.loginTrainee(parseDataStream(req.getInputStream()));
            responseWriter.write(loginResultCode);
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
            String jsonString = parseDataStream(req.getInputStream());
            Exam exam = gson.fromJson(jsonString, Exam.class);
            Trainee trainee = gson.fromJson(jsonString, Trainee.class);

            // Download the file
            String result = exammode.downloadFile(trainee, exam, res); // TODO: Get these values from the request
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
        // Fetches the exam time details of the given trainee
        else if (serviceFlag.toLowerCase().equals(HandsOnUtils.REFRESH_TIME)) {
            // Get the trainee and exam code details
            // Use them to fetch the end time details of the trainee
            // Store the details in the hashmap and write it to the JSON
            HashMap<String, Object> traineeTimerMap = null;
            Exammode exammode = new Exammode();
            traineeTimerMap = exammode.fetchTimerDetails(parseDataStream(req.getInputStream()));
            String jsonObject = gson.toJson(traineeTimerMap);
            System.out.println("Converted Timer: "+jsonObject);
            res.setContentType("application/json");
            // Write the converted JSON data to the response
            responseWriter = res.getWriter();
            responseWriter.write(jsonObject);
            responseWriter.close();
        }
        // Starts the file submission service
        else if (serviceFlag.toLowerCase().equals(HandsOnUtils.SUBMIT_FILE_FLAG)) {
            // Name of the file
            String fileName = urlParts[2];
            SubmitFile submitService = new SubmitFile();
            boolean downloaded = submitService.submitFile(fileName, req.getInputStream());
            responseWriter = res.getWriter();
            if (downloaded) {
                // File successfully downloaded
                responseWriter.write("SUCCESS");
                responseWriter.close();
            }
            else {
                // File successfully downloaded
                responseWriter.write("FAILURE");
                responseWriter.close();
            }
        }
        // Starts the file submission update in database
        else if (serviceFlag.toLowerCase().equals(HandsOnUtils.UPDATE_SUBMISSION_FLAG)) {
            System.out.println("Inside control of update");
            // Exam and trainee details
            String jsonStr = parseDataStream(req.getInputStream());
            Exam exam = gson.fromJson(jsonStr, Exam.class);
            Trainee trainee = gson.fromJson(jsonStr, Trainee.class);

            // Update the submit column
            SubmitFile submitFile = new SubmitFile();
            String result = submitFile.updateSubmitted(exam, trainee);
            System.out.println("Update Result: "+result);
            responseWriter = res.getWriter();
            responseWriter.write(result);
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
