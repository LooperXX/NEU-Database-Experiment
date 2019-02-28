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

@WebServlet(name = "PayFee_Servlet")
public class PayFee_Servlet extends HttpServlet {
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("UTF-8");
        System.out.println("收到用户查询银行卡请求");
        int UID = Integer.parseInt(request.getParameter("customer_id"));
        String type = request.getParameter("type");
        String driver = "oracle.jdbc.OracleDriver";
        String url = "jdbc:oracle:thin:@localhost:1521:XE";
        String user = "TEACHER";
        String sqlPassword = "password";
        PrintWriter out = response.getWriter();
        Object objRtn2 = null;
        switch (type){
            case "0":
                try {
                    Class.forName(driver);
                    Connection conn = DriverManager.getConnection(url, user, sqlPassword);
                    System.out.println("成功连接Oracle数据库");
                    CallableStatement cs = conn.prepareCall("{call QUERY_CARD_NUM_BY_CUSTOMER_ID(?,?)}");
                    cs.setObject(1, UID);
                    cs.registerOutParameter(2, java.sql.Types.VARCHAR);
                    cs.execute();
                    objRtn2 = cs.getObject(2);      //得到返回值
                    System.out.println("向数据库发送用户查询银行卡请求");
                    cs.close();
                    conn.close();
                } catch (ClassNotFoundException e) {
                    System.out.println("Sorry,can`t find the Driver!");
                    e.printStackTrace();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                break;
            case "1":
                try {
                    Class.forName(driver);
                    Connection conn = DriverManager.getConnection(url, user, sqlPassword);
                    System.out.println("成功连接Oracle数据库");
                    CallableStatement cs = conn.prepareCall("{call QUERY_DEVICE_ID_BY_CUSTOMER_ID(?,?)}");
                    cs.setObject(1, UID);
                    cs.registerOutParameter(2, java.sql.Types.VARCHAR);
                    cs.execute();
                    objRtn2 = cs.getObject(2);      //得到返回值
                    System.out.println("向数据库发送用户查询设备ID请求");
                    cs.close();
                    conn.close();
                } catch (ClassNotFoundException e) {
                    System.out.println("Sorry,can`t find the Driver!");
                    e.printStackTrace();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                break;
            case "2":
                try {
                    Class.forName(driver);
                    Connection conn = DriverManager.getConnection(url, user, sqlPassword);
                    System.out.println("成功连接Oracle数据库");
                    CallableStatement cs = conn.prepareCall("{call UPDATE_PAYFEE_BY_DEVICE_ID(?,?,?,?,?)}");
                    long card_id = Long.parseLong(request.getParameter("card_id"));
                    int device_id = Integer.parseInt(request.getParameter("device_id"));
                    int in_fee = Integer.parseInt(request.getParameter("in_fee"));
                    cs.setObject(1, device_id);
                    cs.setObject(2, in_fee);
                    cs.setObject(3, UID);
                    cs.setObject(4, card_id);
                    cs.registerOutParameter(5, java.sql.Types.VARCHAR);
                    cs.execute();
                    objRtn2 = cs.getObject(5);      //得到返回值
                    System.out.println("向数据库发送用户缴费请求");
                    cs.close();
                    conn.close();
                } catch (ClassNotFoundException e) {
                    System.out.println("Sorry,can`t find the Driver!");
                    e.printStackTrace();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
                break;
        }
        JsonObject res = new JsonObject();
        res.addProperty("type", "OK");
        assert objRtn2 != null;
        res.addProperty("line1", objRtn2.toString());
        out.print(res);
        out.flush();
        out.close();
        out.close();
    }

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doPost(request, response);
    }
}
