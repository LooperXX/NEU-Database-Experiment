package Servlet;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import java.sql.*;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet(name = "Query_Servlet")
public class Query_Servlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            response.setCharacterEncoding("UTF-8");
            response.setContentType("UTF-8");
            System.out.println("收到用户查询欠费金额请求");
            int UID = Integer.parseInt(request.getParameter("customer_id"));
            System.out.println(UID);
            String driver = "oracle.jdbc.OracleDriver";
            String url = "jdbc:oracle:thin:@localhost:1521:XE";
            String user = "TEACHER";
            String sqlPassword = "password";
            Object objRtn2 = null;
            Object objRtn3 = null;
            Object objRtn4 = null;
            try {
                Class.forName(driver);
                Connection conn = DriverManager.getConnection(url, user, sqlPassword);
                System.out.println("成功连接Oracle数据库");
                CallableStatement cs = conn.prepareCall("{call query_PAID_Fee_By_Customer_ID(?,?,?,?)}");
                cs.setObject(1, UID);
                cs.registerOutParameter(2, java.sql.Types.VARCHAR);
                cs.registerOutParameter(3, java.sql.Types.VARCHAR);
                cs.registerOutParameter(4, java.sql.Types.VARCHAR);
                cs.execute();
                objRtn2 = cs.getObject(2);      //得到返回值
                objRtn3 = cs.getObject(3);      //得到返回值
                objRtn4 = cs.getObject(4);      //得到返回值
                System.out.println("向数据库发送用户查询欠费金额请求");
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
            res.addProperty("line2", objRtn3.toString());
            res.addProperty("line3", objRtn4.toString());
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
