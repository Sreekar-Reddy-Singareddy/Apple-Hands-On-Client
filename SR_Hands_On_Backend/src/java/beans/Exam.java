/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package beans;

/**
 *
 * @author bros
 */
public class Exam {
    
    private long examCode = 0l;
    private String fileType = "";

    public Exam() {
        
    }

    public long getExamCode() {
        return examCode;
    }

    public void setExamCode(long examCode) {
        this.examCode = examCode;
    }

    public String getFileType() {
        return fileType;
    }

    public void setFileType(String fileType) {
        this.fileType = fileType;
    }
    
    
    
}
