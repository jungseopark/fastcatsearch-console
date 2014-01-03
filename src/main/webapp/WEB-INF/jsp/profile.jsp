<%@page import="org.json.JSONObject"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%
JSONObject userInfo = (JSONObject)request.getAttribute("userInfo");
%>

<c:import url="inc/common.jsp" />
<html>
<head>
<c:import url="inc/header.jsp" />
<script>
$(document).ready(function(){
	$("#user-update-form").validate({
		rules: {
			reqPassword: {
				equalTo: "#password"
			}
		}
	});
	
	$("#user-update-form").submit(function(e) {
		
		e.preventDefault();
		if(! $(this).valid()){
			return false;
		} 

		$.ajax({
			url: PROXY_REQUEST_URI,
			type: "POST",
			dataType: "json",
			data: $(this).serializeArray(),
			success: function(response, statusText, xhr, $form){
				if(response["success"]=="true") {
					$("div.modal").modal("hide");
					noty({text: "update success", type: "success", layout:"topRight", timeout: 3000});
					setTimeout(function() {
						location.href = location.href;
						
					},1000);
				} else {
					noty({text: "update fail : "+response["message"], type: "error", layout:"topRight", timeout: 5000});
				}
				
			}, fail: function() {
				noty({text: "Can't submit data", type: "error", layout:"topRight", timeout: 5000});
			}
			
		});
		return false;
		
	});
});

</script>
</head>
<body>
<c:import url="inc/mainMenu.jsp" />
<div id="container" class="sidebar-closed">
	<div id="content">
		<div class="container">
			<!-- Breadcrumbs line -->
			<div class="crumbs">
				<ul id="breadcrumbs" class="breadcrumb">
					<li><i class="icon-home"></i> <a href="javascript:void(0);">My Profile</a>
					</li>
				</ul>
	
			</div>
			<!-- /Breadcrumbs line -->
			<!--=== Page Header ===-->
			<div class="page-header">
				<div class="page-title">
					<h3>My Profile</h3>
					
				</div>
			</div>
			<!-- /Page Header -->
			
			
			<form id="user-update-form">
				<input type="hidden" name="uri" value="/settings/authority/put-my-info"/>
				
				<div class="col-md-12">
					<div class="widget">
						<div class="widget-header">
							<h4>General Information</h4>
						</div>
						<div class="widget-content">
							<div class="row">
								<div class="col-md-12 form-horizontal">
									<div class="form-group">
										<label class="col-md-2 control-label">User ID:</label>
										<div class="col-md-3" style="padding-top: 6px;"><%=userInfo.optString("userId") %></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">Group:</label>
										<div class="col-md-3" style="padding-top: 6px;"><%=userInfo.optString("groupName") %></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">User Name:</label>
										<div class="col-md-3"><input type="text" name="name" class="form-control fcol2 required" value="<%=userInfo.optString("name")%>" /></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">Email Address:</label>
										<div class="col-md-3"><input type="text" name="email" class="form-control fcol3 email" value="<%=userInfo.optString("email") %>" /></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">SMS Number:</label>
										<div class="col-md-3"><input type="text" name="sms" class="form-control fcol2 digits" value="<%=userInfo.optString("sms") %>" /></div>
									</div>
									
								</div>
							</div>
						</div>
					</div>
				</div>
				<div class="col-md-12">
					<div class="widget">
						<div class="widget-header">
							<h4>Password</h4>
						</div>
						<div class="widget-content">
							<div class="row">
								<div class="col-md-12 form-horizontal">		
									<div class="form-group">
										<label class="col-md-2 control-label">Old Password:</label>
										<div class="col-md-3"><input type="password" name="password" class="form-control fcol3" placeholder="Leave empty for no password-change"></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">New Password:</label>
										<div class="col-md-3"><input type="password" id="password" name="newPassword" class="form-control fcol3" minlength="4" placeholder="Leave empty for no password-change"></div>
									</div>
									<div class="form-group">
										<label class="col-md-2 control-label">Repeat New Password:</label>
										<div class="col-md-3"><input type="password" name="reqPassword" class="form-control fcol3" minlength="4" placeholder="Leave empty for no password-change"></div>
									</div>
								</div>
							</div>
						</div>
					</div> <!-- /.widget -->
				</div>
				<div>
					<div class="form-actions">
						<input type="submit" value="Update Profile" class="btn btn-primary pull-right">
					</div>
				</div>
			
			</form>
		</div>
	</div>
</div>
</body>
</html>