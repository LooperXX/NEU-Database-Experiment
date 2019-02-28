package Servlet;

import com.google.gson.JsonObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

@WebServlet(name = "Correct_Servlet")
public class Correct_Servlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            response.setCharacterEncoding("UTF-8");
            response.setContentType("UTF-8");
            System.out.println("收到用户冲正请求");
            int UID = Integer.parseInt(request.getParameter("customer_id"));
            int BT_ID = Integer.parseInt(request.getParameter("BT_ID"));
            System.out.println(UID);
            String driver = "oracle.jdbc.OracleDriver";
            String url = "jdbc:oracle:thin:@localhost:1521:XE";
            String user = "TEACHER";
            String sqlPassword = "password";
            Object objRtn2 = null;
            try {
                Class.forName(driver);
                Connection conn = DriverManager.getConnection(url, user, sqlPassword);
                System.out.println("成功连接Oracle数据库");
                CallableStatement cs = conn.prepareCall("{call UPDATE_CORRECT_BY_BT_ID(?,?,?)}");
                cs.setObject(1, BT_ID);
                cs.setObject(2, UID);
                cs.registerOutParameter(3, java.sql.Types.VARCHAR);
                cs.execute();
                objRtn2 = cs.getObject(3);      //得到返回值
                System.out.println("向数据库发送用户冲正请求");
                cs.close();
                conn.close();
            } catch (ClassNotFoundException e) {
                System.out.println("Sorry,can`t find the Driver!");
                e.printStackTrace();
            } catch (SQLException e) {
                e.printStackTrace();
            }
            PrintWriter out = response.getWriter();
            JsonObject res = new JsonObject();
            res.addProperty("type", "OK");
            res.addProperty("line1", objRtn2.toString());
            out.print(res);
            out.flush();
            out.close();
        } catch (Exception e) {
            e.printStackTrace();
            response.sendError(404);
        }
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
