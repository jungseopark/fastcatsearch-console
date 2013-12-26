<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.json.*"%>
<%
%>


<c:set var="ROOT_PATH" value="../.." scope="request" />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />

<script>
$(document).ready(function(){
	$('#keyword_tab a').on('shown.bs.tab', function (e) {
		var targetId = e.target.hash;
		
		if(targetId == "#tab_keyword_overview"){
			loadToTab("overview.html", null, targetId);
		}else{
			var aObj = $(e.target);
			if($(targetId).text() != ""){
				//이미 로드되어있으면 다시 로드하지 않음.
				return;
			}
			var keywordId = aObj.attr("_id");
			var keywordType = aObj.attr("_type");
		}
	});
	
	loadKeywordTab("relate","total","",1);
	
});

function loadKeywordTab(keywordType,category, isEditable, pageNo) {
	loadToTab(keywordType+"/keywordList.html", {
		 category:category
		,isEditable:isEditable
		,pageNo:pageNo}, "#tab_keyword_overview");
}

</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="keyword" />
			<c:param name="mcat" value="${keywordType}" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> Manager</li>
						<li class="current"> keyword</li>
						<li class="current"> ${keywordType}</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>${analysisId }</h3>
					</div>
				</div>
				<!-- /Page Header -->
				<div class="tabbable tabbable-custom tabbable-full-width">
					<ul id="keyword_tab" class="nav nav-tabs">
						<li class="active"><a href="#tab_keyword_overview" data-toggle="tab">Overview</a></li>
						
					</ul>
					<div class="tab-content row">

						<!--=== Overview ===-->
						<div class="tab-pane active" id="tab_keyword_overview"></div>
						
						<!-- //tab field -->
					</div>
					<!-- /.tab-content -->
				</div>

						
				<!-- /Page Content -->
			</div>
		</div>
	</div>
</body>
</html>