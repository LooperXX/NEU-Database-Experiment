<%--
  Created by IntelliJ IDEA.
  User: LooperXX
  Date: 2018/7/8
  Time: 15:50
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java"%>
<%@ page import="java.sql.*" %>
<%
    String driver = "oracle.jdbc.OracleDriver";
    String url = "jdbc:oracle:thin:@localhost:1521:XE";
    String user = "TEACHER";
    String sqlPassword = "password";
    try {
        int userID = Integer.parseInt(request.getParameter("text"));
        String password = request.getParameter("psw");
        String user_type = request.getParameter("select");
        System.out.println(userID + "##" + password +  "##" + user_type);
        Class.forName(driver);
        Connection conn = DriverManager.getConnection(url, user, sqlPassword);
        System.out.println("成功连接Oracle数据库");
        CallableStatement cs = conn.prepareCall("{call QUERY_VALIDATE_LOGIN(?,?,?,?,?)}");
        cs.setObject(1, userID);
        cs.setObject(2, password);
        cs.setObject(3, user_type);
        cs.registerOutParameter(4, java.sql.Types.VARCHAR);
        cs.registerOutParameter(5, java.sql.Types.VARCHAR);
        cs.execute();
        Object objRtn1 = cs.getObject(4);      //得到返回值
        Object objRtn2 = cs.getObject(5);      //得到返回值
        System.out.println(objRtn1);
        System.out.println(objRtn2);
        cs.close();
        conn.close();
        if (objRtn1.toString().equals("RIGHT")){
            session.setAttribute("UNAME",objRtn2);
            session.setAttribute("UTYPE",user_type);
            session.setAttribute("UID",userID);
            switch (user_type){
                case "1":
                    out.println("<script>window.location.href='"+"customer.jsp"+"'</script>");
                    break;
                case "2":
                    out.println("<script>window.location.href='"+"mt_reader.jsp"+"'</script>");
                    break;
                case "3":
                    out.println("<script>window.location.href='"+"admin.jsp"+"'</script>");
                    break;
                default:
                    out.println("<script>alert(" + "登陆失败" + ");</script>");
                    out.println("<script>window.location.href='"+"index.jsp"+"'</script>");
                    break;
            }
        }else {
            String message = "您的账号或密码有误，登陆失败";
            out.println("<SCRIPT LANGUAGE='JavaScript'>");
            out.println("<!--");
            out.println("alert('"+message+"')");
            out.println("//-->");
            out.println("</SCRIPT>");
            out.println("<script>window.location.href='" + "index.jsp" + "'</script>");
        }
    } catch (ClassNotFoundException e) {
        System.out.println("Sorry,can`t find the Driver!");
        e.printStackTrace();
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>
<html>
<head>
    <title>login</title>
</head>
<body>
    登录失败
</body>
</html>
