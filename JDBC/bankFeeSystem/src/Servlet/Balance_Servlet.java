package Servlet;

import com.google.gson.JsonObject;
import org.json.JSONArray;
import org.json.JSONObject;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.*;
import java.text.SimpleDateFormat;

@WebServlet(name = "Balance_Servlet")
public class Balance_Servlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        try {
            response.setCharacterEncoding("UTF-8");
            response.setContentType("UTF-8");
            System.out.println("收到用户查看余额表请求");
            int UID = Integer.parseInt(request.getParameter("customer_id"));
            System.out.println(UID);
            String driver = "oracle.jdbc.OracleDriver";
            String url = "jdbc:oracle:thin:@localhost:1521:XE";
            String user = "TEACHER";
            String sqlPassword = "password";
            JSONArray jsonArray = new JSONArray();
            try {
                Class.forName(driver);
                Connection conn = DriverManager.getConnection(url, user, sqlPassword);
                System.out.println("成功连接Oracle数据库");
                CallableStatement cs = conn.prepareCall("{call PACKAGE_BALANCE_CURSOR.QUERY_BALANCE_BY_CUSTOMER_ID(?,?)}");
                cs.setObject(1, UID);
                cs.registerOutParameter(2, oracle.jdbc.OracleTypes.CURSOR);
                cs.execute();
                System.out.println("向数据库发送收到用户查看余额表请求");
                ResultSet rSet=(ResultSet) cs.getObject(2);
                while(rSet.next()){
                    JSONArray jsonArray1 = new JSONArray();
                    jsonArray1.put(rSet.getString(1));
                    jsonArray1.put(rSet.getString(2));
                    jsonArray1.put(rSet.getString(3));
                    jsonArray1.put(rSet.getString(4));
                    jsonArray1.put(rSet.getString(5));
                    jsonArray1.put(rSet.getString(6));
                    jsonArray1.put(rSet.getString(7));
                    jsonArray1.put(rSet.getString(8));
                    jsonArray.put(jsonArray1);
                }
                rSet.close();
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
            res.addProperty("balance", String.valueOf(jsonArray));
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
