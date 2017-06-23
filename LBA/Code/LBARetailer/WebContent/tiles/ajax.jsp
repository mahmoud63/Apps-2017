<%@page import="java.net.URLDecoder"%>
<%@page import="java.io.File"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="com.helper.FileDownloadHelper"%>
<%@page import="com.entity.RetailerMasterModel"%>
<%@page import="com.entity.UserAccountModel"%>
<%@page import="java.util.List"%>
<%@page import="java.io.OutputStream"%>
<%@page import="java.io.IOException"%>

<%@page import="com.entity.UserModel"%>
<%@page import="java.io.ObjectOutputStream"%>

<%@page import="com.database.ConnectionManager"%>
<%@page import="com.helper.StringHelper"%>
<%@page import="java.util.HashMap"%>
<%@ page trimDirectiveWhitespaces="true" %>
<%
	String sMethod = StringHelper.n2s(request.getParameter("methodId"));
	String returnString = "";
	boolean bypasswrite=false;

	HashMap parameters = StringHelper.displayRequest(request);
	if (sMethod.equalsIgnoreCase("fnDeleteAds")) {
		String adsId = StringHelper.n2s(request.getParameter("adsId"));
		System.out.println("adsId  "+adsId );
	String q="delete FROM advertisement where adsId="+adsId;
	System.out.println("adsId  "+q);
	ConnectionManager.executeUpdate(q);
	returnString="false";
	} 
	
	
	else if (sMethod.equalsIgnoreCase("insertWishlist")) {
		String adsId = StringHelper.n2s(request.getParameter("adsId"));
		String userId =URLDecoder.decode(StringHelper.n2s(request.getParameter("userId"))) ;
		ConnectionManager.insertWishlist(adsId, userId);
		
	}
	else if (sMethod.equalsIgnoreCase("setLocation")) {
		String latlong = StringHelper.n2s(request.getParameter("latlong"));
		String address =URLDecoder.decode(StringHelper.n2s(request.getParameter("address"))) ;
		session.setAttribute("latlong", latlong);
		session.setAttribute("address", address);
	}
	else if (sMethod.equalsIgnoreCase("updateProducts")) {
		String products = StringHelper.n2s(request.getParameter("products"));
		String userId = StringHelper.n2s(request.getParameter("userId"));
		String typeId = StringHelper.n2s(request.getParameter("typeId"));
		String q="";
		if(typeId.equalsIgnoreCase("2")){
	q="update retailermaster set products='"+products+"' where retailerId="+userId;
		}else if(typeId.equalsIgnoreCase("1")){
	q="update useraccount set products='"+products+"' where userid="+userId;
		}
	
	ConnectionManager.executeUpdate(q);
	returnString="false";
	} 
	else if (sMethod.equalsIgnoreCase("deleteProduct")) {
		String products = StringHelper.n2s(request.getParameter("products"));
		products=products.replace(",", "");
		String userId = StringHelper.n2s(request.getParameter("userId"));
		String typeId = StringHelper.n2s(request.getParameter("typeId"));
		String q="delete FROM `whishlist` where userId="+products;
		int status=ConnectionManager.executeUpdate(q);
		if(status>0)
		{
			returnString="true";
		}
	returnString="false";
	} 
	else if (sMethod.equalsIgnoreCase("addView")) {
		String userId = StringHelper.n2s(request.getParameter("reatailerId"));
		String adId = StringHelper.n2s(request.getParameter("adId"));
		String q="insert into adsvisit (adsId, userId) values(?,?)";
		ConnectionManager.executeUpdate(q,adId,userId);
		returnString="false";
	}
	else if (sMethod.equalsIgnoreCase("checkLogin")) {
		Object um= ConnectionManager.checkLogin(parameters);
		if(um!=null){
	if(um instanceof UserAccountModel){
		UserAccountModel umna=(UserAccountModel)um;
		session.setAttribute("USER_MODEL", umna);
		session.setAttribute("retailer", false);
		if(umna.getRoleId().equalsIgnoreCase("A")){
			returnString="true_a";
		}else{
			returnString="true_c";
		}
	}
	else if(um instanceof RetailerMasterModel){
		session.setAttribute("USER_MODEL", (RetailerMasterModel)um);
		returnString="true_r";
		session.setAttribute("retailer", true);
	}
	

		}else{
	returnString="false";
		}
	}else if (sMethod.equalsIgnoreCase("saveCustomer")) {
		returnString = ConnectionManager.saveCustomer(parameters);
	}else if (sMethod.equalsIgnoreCase("saveRetailer")) {
		returnString = ConnectionManager.saveRetailer(parameters);
	}
	else if (sMethod.equalsIgnoreCase("fnPostAds")) {
		returnString = ConnectionManager.fnPostAds(parameters);
	}
	else if (sMethod.equalsIgnoreCase("addContact")) {
		ConnectionManager.addContact(parameters);
	} else if (sMethod.equalsIgnoreCase("checkLoginPhone")) {
		OutputStream responseBody=response.getOutputStream();
		bypasswrite=true;
		UserModel um= ConnectionManager.checkLoginPhone(parameters);
		if(um!=null){
	session.setAttribute("USER_MODEL", um);
	returnString="true";
		}else{
	returnString="false";
		}
		ObjectOutputStream os=new ObjectOutputStream(responseBody);
		os.writeObject(um);
		os.flush();
		os.close();
	}
	
	
	else if (sMethod.equalsIgnoreCase("logout")) {
	session.removeAttribute("USER_MODEL");
	bypasswrite=true;
	response.sendRedirect(request.getContextPath()+"/pages/index.jsp");

	}
	else if (sMethod.equalsIgnoreCase("downloadImage")) {
		int imageId = StringHelper.n2i(request.getParameter("imageId"));	
		String q="Select img from adimages where adsId="+imageId;
		ConnectionManager.getImage(q,response.getOutputStream());
		return;
	}
	else if (sMethod.equalsIgnoreCase("uploadPhoto")) {	
		OutputStream responseBody=response.getOutputStream();
		parameters= FileDownloadHelper.parseMultipartRequest(request);
		String uploaded_file = StringHelper.n2s(parameters.get("uploaded_file"));
		String adId = StringHelper.n2s(parameters.get("adId"));
		if(uploaded_file.lastIndexOf("/")!=-1){
	uploaded_file=uploaded_file.substring(uploaded_file.lastIndexOf("/")+1);	
		}
		if(uploaded_file.lastIndexOf("\\")!=-1){
	uploaded_file=uploaded_file.substring(uploaded_file.lastIndexOf("\\")+1);	
		}
		FileItem fi=(FileItem) parameters.get("uploaded_file_ITEM");
		File file=new File(uploaded_file);
		fi.write(file);
		boolean success=ConnectionManager.saveImage(fi.get(),fi.getName(),adId);
		//StegoAction.delegateAction(StringHelper.getParameters(Stegnography.getData(new String(s))) , response.getOutputStream());
		if(success)
	responseBody.write(("File Uploaded Successfully").getBytes());
		else
	responseBody.write(("Error Uploading File ").getBytes());
		
		responseBody.flush();
		  
	
	out.clear(); // where out is a JspWriter
	out = pageContext.pushBody();
		}
	if(!bypasswrite){
	out.println(returnString);
	
	}
%>
