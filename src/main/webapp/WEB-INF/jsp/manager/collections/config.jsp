<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.jdom2.*"%>
<%@page import="java.util.*"%>
<%
	Document document = (Document) request.getAttribute("document");

%>
<c:set var="ROOT_PATH" value="../.." />
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<script>
$(document).ready(function(){
	$("#collection-config-form").validate();
	
	$("#collection-config-form").submit(function(e) {
		var postData = $(this).serializeArray();
		$.ajax({
				url : PROXY_REQUEST_URI,
				type: "POST",
				data : postData,
				dataType : "json",
				success:function(data, textStatus, jqXHR) {
					try {
						if(data.success) {
							location.href = location.href;
						}else{
							noty({text: "Update failed", type: "error", layout:"topRight", timeout: 5000});
						}
					} catch (e) {
						noty({text: "Update error : "+e, type: "error", layout:"topRight", timeout: 5000});
					}
					
				}, error: function(jqXHR, textStatus, errorThrown) {
					noty({text: "Update error. status="+textStatus+" : "+errorThrown, type: "error", layout:"topRight", timeout: 5000});
				}
		});
		e.preventDefault(); //STOP default action
	});
});

</script>
</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
		<c:import url="${ROOT_PATH}/manager/sideMenu.jsp">
			<c:param name="lcat" value="collections" />
			<c:param name="mcat" value="${collectionId}" />
			<c:param name="scat" value="config" />
		</c:import>
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> Manager</li>
						<li class="current"> Collections</li>
						<li class="current"> VOL</li>
						<li class="current"> Settings</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>Settings</h3>
					</div>
				</div>
				<!-- /Page Header -->
				
				<%
				Element root = document.getRootElement();
				String collectionName = root.getChildText("name");
				String indexNode = root.getChildText("index-node");
				Element dataNodeList = root.getChild("data-node-list");
				Element dataPlanConfig = root.getChild("data-plan");
				List<Element> nodeList = dataNodeList.getChildren("node");
				
				
				String dataNodeListString = "";
				for(int i=0;i<nodeList.size(); i++){
					Element el = nodeList.get(i);
					if(dataNodeListString.length() > 0){
						dataNodeListString += ", ";
					}
					dataNodeListString += el.getText();
				}
				
				%>
				<form id="collection-config-form">
					<input type="hidden" name="uri" value="/management/collections/update-config"/>
					<input type="hidden" name="collectionId" value="${collectionId}"/>
					
					<div class="col-md-12">
						<div class="widget">
							<div class="widget-header">
								<h4>General Information</h4>
							</div>
							<div class="widget-content">
								<div class="row">
									<div class="col-md-12 form-horizontal">
										<div class="form-group">
											<label class="col-md-2 control-label">Collection Name:</label>
											<div class="col-md-3"><input type="text" name="collectionName" class="form-control required" value="<%=collectionName %>"></div>
										</div>
									</div>
									<div class="col-md-12 form-horizontal">
										<div class="form-group">
											<label class="col-md-2 control-label">Index Node:</label>
											<div class="col-md-3"><input type="text" name="indexNode" class="form-control required fcol2" value="<%=indexNode %>"></div>
										</div>
									</div>
								</div>
							</div>
						</div> <!-- /.widget -->
					</div>
					
					<div class="col-md-12">
						<div class="widget">
							<div class="widget-header">
								<h4>Data Plan</h4>
							</div>
							<div class="widget-content">
								<div class="row">
									<div class="col-md-8 form-horizontal">
										
										<div class="form-group">
											<label class="col-md-4 control-label">Data Node List :</label>
											<div class="col-md-8"><input type="text" name="dataNodeList" class="form-control required" value="<%=dataNodeListString %>"></div>
										</div>
										<div class="form-group">
											<label class="col-md-4 control-label">Data-sequence-cycle :</label>
											<div class="col-md-8"><input type="text" name="dataSequenceCycle" class="form-control required digits fcol1" value="<%=dataPlanConfig.getChildText("data-sequence-cycle") %>" maxlength="1" minlength="1"></div>
										</div>
	
										<div class="form-group">
											<label class="col-md-4 control-label">Segment-revision-backup-size :</label>
											<div class="col-md-8"><input type="text" name="segmentRevisionBackupSize" class="form-control required digits fcol1" value="<%=dataPlanConfig.getChildText("segment-revision-backup-size") %>" maxlength="2" minlength="1"></div>
										</div>
										<div class="form-group">
											<label class="col-md-4 control-label">Segment-document-limit :</label>
											<div class="col-md-8"><input type="text" name="segmentDocumentLimit" class="form-control required digits fcol2" value="<%=dataPlanConfig.getChildText("segment-document-limit") %>"></div>
										</div>
									</div>
								</div>
							</div>
						</div>
						
						<div class="form-actions">
							<input type="submit" value="Update Settings" class="btn btn-primary pull-right">
						</div>
					</div>
				
				</form>
				
				
				
			</div>
		</div>
	</div>
</body>
</html>