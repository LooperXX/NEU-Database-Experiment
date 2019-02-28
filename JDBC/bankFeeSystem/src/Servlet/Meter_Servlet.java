package Servlet;

import com.google.gson.JsonObject;
import oracle.jdbc.oracore.OracleTypeDATE;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.text.SimpleDateFormat;

@WebServlet(name = "Meter_Servlet")
public class Meter_Servlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try{
            response.setCharacterEncoding("UTF-8");
            response.setContentType("UTF-8");
            System.out.println("收到抄表员抄表请求");
            int UID = Integer.parseInt(request.getParameter("customer_id"));
            int device_id = Integer.parseInt(request.getParameter("device_id"));
            int mt_number = Integer.parseInt(request.getParameter("mt_number"));
            String date_s = request.getParameter("mt_date");
            SimpleDateFormat tempDate = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date date = tempDate.parse(date_s); //格式化
            java.sql.Date mt_date = new java.sql.Date(date.getTime());
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
                CallableStatement cs = conn.prepareCall("{call UPDATE_METER_LOG_BY_DEVICE_ID(?,?,?,?,?)}");
                cs.setObject(1, device_id);
                cs.setDate(2, mt_date);
                cs.setObject(3, mt_number);
                cs.setObject(4, UID);
                cs.registerOutParameter(5, java.sql.Types.VARCHAR);
                cs.execute();
                objRtn2 = cs.getObject(5);      //得到返回值
                System.out.println("向数据库发送抄表员抄表请求");
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
            assert objRtn2 != null;
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
