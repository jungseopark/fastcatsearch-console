<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="org.jdom2.*"%>
<%@page import="java.util.*"%>
<%@page import="org.json.*" %>
<%
	Document document = (Document) request.getAttribute("document");
	JSONObject typeListObj = (JSONObject) request.getAttribute("typeList");
	JSONArray typeList = typeListObj.optJSONArray("typeList");
%>
<c:set var="ROOT_PATH" value="../.." scope="request"/>
<c:import url="${ROOT_PATH}/inc/common.jsp" />
<html>
<head>
<c:import url="${ROOT_PATH}/inc/header.jsp" />
<style>
tbody[key=_index-list_] textarea {height: 30px}
</style>
<script>

$(document).ready(function(){
	
	$("#schemaForm").validate();
	
	$("#schemaForm").submit(function(event){
		event.preventDefault();
		var form = $(this)[0];
		var elements = form.elements;
		
		if(! $(this).valid()){
			return;
		} 
		var formData = {};
		var paramInx = 0;
		var prevKey = "";
		for(var inx=0; inx < elements.length; inx++) {
			if(elements[inx].name=="KEY_NAME") {
				paramInx ++; 
			}
			var pattern = /^(_[a-zA-Z_-]+_)([0-9]+)(-[a-zA-Z]+)$/g;
			var matcher = pattern.exec(elements[inx].name);
			if(matcher!=null) {
				var key = matcher[1];
				if(key!=prevKey) {
					paramInx = 0;
				}
				
				var value = "";
				if(elements[inx].getAttribute("type") != null && 
					(elements[inx].getAttribute("type").toLowerCase() == "checkbox"
					|| elements[inx].getAttribute("type").toLowerCase() == "radio")) {
					if(elements[inx].checked) {
						value = elements[inx].value;
					}
				} else {
					value = elements[inx].value;
				}
				
				formData[(matcher[1]+paramInx+matcher[3])] = value;
				prevKey = key;
			}
		}
		
		$.ajax({
			url: "workSchemaSave.html",
			type: "POST",
			dataType:"json",
			data:formData,
			success:function(response, status) {
				if(response.success) {
					$.noty.closeAll();
					noty({text: "Schema update success", type: "success", layout:"topRight", timeout: 3000});
				} else {
					noty({text: response.errorMessage, type: "error", layout:"topRight", timeout: 0}); //클릭해야 사라진다.
				}
			}, fail:function() {
				noty({text: "Can't submit data", type: "error", layout:"topRight", timeout: 5000});
			}
		});
		return;
	});
	
	//select 로 필드타입선택시 size를 readonly 로 바꾼다.
	var selectFieldFunction = function() {
		var o = $(this).parents("tr").find("input.field-type-size");
		if($(this).val() != "ASTRING" && $(this).val() != "STRING") {
			o.val("");
			o.prop("readonly", true);
		}else{
			o.prop("readonly", false);
		}
	};

	var addRowFunction = function(){
		var tbody = $(this).parents("tbody");
		var key = tbody.attr("key"); //_field-list_
		var pivotTr = $(this).parents("tr");
		
		var trTemplate = $("#schema_template tr[key="+key+"]");
		//var keyName = trTemplate.find("input[name=KEY_NAME]").val(); //_field-list_0
		var newTr = trTemplate.clone();
		
		var newIndex = new Date().getTime();
		
		var newKeyName = key + newIndex;
		
		newTr.find("input[name=KEY_NAME]").val(newKeyName);
		newTr.find("input, select, textarea").each(function() {
			var name = $(this).attr("name");
			if(name != "KEY_NAME") {
				$(this).attr("name", newKeyName + "-" + name);
			}
		});
		
		//remove tooltip object
		newTr.find("div.tooltip.fade.top.in").remove();
		//link event
		newTr.find("a.addRow").click(addRowFunction).tooltip(addRowTooltip);
		newTr.find("a.deleteRow").click(deleteRowFunction).tooltip(deleteRowTooltip);
		
		newTr.find(".select-field-type").change(selectFieldFunction);
		pivotTr.after(newTr);
		
		var lineCount = tbody.children("tr:not(.no-entry)").length;
		if(lineCount > 0){
			tbody.children("tr.no-entry").hide();
		}
		
	};
	
	var deleteRowFunction = function() {
		var trElement = $(this).parents("tr");
		var tbody = trElement.parents("tbody");
		
		trElement.remove();
		
		var lineCount = tbody.children("tr:not(.no-entry)").length;
		if(lineCount == 0){
			tbody.children("tr.no-entry").show();
		}
		
	};
	
	var addRowTooltip = {title : "Insert 1 below"};
	var deleteRowTooltip = {title : "Delete row"};
	
	$("a.addRow").tooltip(addRowTooltip);
	$("a.deleteRow").tooltip(deleteRowTooltip);
	
	$("a.addRow").click(addRowFunction);
	$("a.deleteRow").click(deleteRowFunction);
	
	$(".select-field-type").change(selectFieldFunction);
	
});

	function saveSchema(){
		$("#schemaForm").submit();
	}
	function removeSchema(){
		
		requestProxy("POST", {uri:"/management/collections/schema/remove.json", collectionId:"${collectionId}", type:"workSchema"},
			"json", 
			function(response, status) {
				if(response.success) {
					submitGet("schema.html");
				} else {
					noty({text: "Work schema remove fail", type: "error", layout:"topRight", timeout: 5000});
				}
			}, function() {
				noty({text: "Can't submit data", type: "error", layout:"topRight", timeout: 5000});
			});
	}
	
	function reloadSchema(){
		location.href = location.href;
	}
	
	function backToSchema(){
		submitGet("workSchema.html", {});
	}
</script>

</head>
<body>
	<c:import url="${ROOT_PATH}/inc/mainMenu.jsp" />
	<div id="container">
	 <c:import url="${ROOT_PATH}/manager/sideMenu.jsp" >
	 	<c:param name="lcat" value="collections"/>
	 	<c:param name="mcat" value="${collectionId}" />
		<c:param name="scat" value="schema" />
	 </c:import>
		
		<div id="content">
			<div class="container">
				<!-- Breadcrumbs line -->
				<div class="crumbs">
					<ul id="breadcrumbs" class="breadcrumb">
						<li><i class="icon-home"></i> Manager</li>
						<li class="current"> Collections</li>
						<li class="current"> ${collectionId}</li>
						<li class="current"> Schema</li>
					</ul>

				</div>
				<!-- /Breadcrumbs line -->

				<!--=== Page Header ===-->
				<div class="page-header">
					<div class="page-title">
						<h3>Work Schema</h3>
					</div>
					<div class="btn-group" style="float:right; padding: 25px 0;">
						<a href="javascript:removeSchema(0);" class="btn btn-sm btn-danger"><span class="icon-trash"></span> Remove</a>
						<a href="javascript:saveSchema();" class="btn btn-sm" style="margin-left:5px"><span class="icon-ok"></span> Save</a>
						<a href="javascript:reloadSchema();" class="btn btn-sm" style="margin-left:5px"><i class="icon-refresh"></i></a>
						<a href="javascript:backToSchema();" class="btn btn-sm"><span class="icon-eye-open"></span> View</a>
					</div>
				</div>
				<!-- /Page Header -->
				
				
				<!--=== Page Content ===-->
				<%
				Element root = document.getRootElement();
				Element el = root.getChild("field-list");
				%>
				<form id="schemaForm">
				
					<div class="col-md-12">
						<div class="widget">
							<div class="widget-header">
								<h4>Fields</h4>
							</div>
			
							<div class="widget-content">
	
								<table id="schema_table_fields" class="table table-bordered table-hover table-highlight-head table-condensed">
									
									<thead>
										<tr>
											<th class="fcol2">ID</th>
											<th class="fcol2">Name</th>
											<th class="fcol2">Type</th>
											<th class="fcol2">Length</th>
											<th class="fcol1">Store</th>
											<th class="fcol1">Remove Tags</th>
											<th class="fcol1">Multi Value</th>
											<th class="fcol1">Multi Value Delimiter</th>
											<th class="fcol1-1"></th>
										</tr>
									</thead>
									<tbody key="_field-list_">
									<%
									root = document.getRootElement();
									el = root.getChild("field-list");
									if(el != null){
										List<Element> fieldList = el.getChildren();
										%>
										<tr class="no-entry <%=fieldList.size() > 0 ? "hide2" : ""%>">
											<td colspan="9"><a href="javascript:void(0)" class="addRow">Add Entry</a></td>
										</tr>
										<%
										for(int i = 0; i <fieldList.size(); i++){
											Element field = fieldList.get(i);
											String id = field.getAttributeValue("id");
											String type = field.getAttributeValue("type");
											String name = field.getAttributeValue("name", "");
											String source = field.getAttributeValue("source", "");
											String size = field.getAttributeValue("size", "");
											String store = field.getAttributeValue("store", "true");
											String removeTag = field.getAttributeValue("removeTag", "");
											String multiValue = field.getAttributeValue("multiValue", "false");
											String multiValueDelimiter = field.getAttributeValue("multiValueDelimiter", "");
										%>
										<tr>
											<td><input type="hidden" name="KEY_NAME" value="_field-list_<%=i %>" /><input type="text" name="_field-list_<%=i%>-id" class="form-control required" value="<%=id %>"></td>
											<td><input type="text" name="_field-list_<%=i%>-name" class="form-control required" value="<%=name %>"></td>
											
											<td><select class="select_flat form-control required select-field-type" name="_field-list_<%=i %>-type" >
											<%
											boolean isSizeReadonly = !(type.equalsIgnoreCase("STRING") || type.equalsIgnoreCase("ASTRING"));

											for(int typeInx=0;typeInx < typeList.length(); typeInx++) { 
												String typeStr = typeList.optString(typeInx);
											%>
											<option value="<%=typeStr %>" <%=typeStr.equals(type)?"selected":"" %>><%=typeStr %></option>
											<%
											}
											%>
											</select></td>
											
											<td><input type="text" name="_field-list_<%=i%>-size" class="form-control digit field-type-size" value="<%=size %>" <%=isSizeReadonly?"readonly":"" %>></td>
											<td><label class="checkbox"><input type="checkbox" value="true" name="_field-list_<%=i%>-store" <%="true".equalsIgnoreCase(store) ? "checked" : "" %>></label></td>
											<td><label class="checkbox"><input type="checkbox" value="true" name="_field-list_<%=i%>-removeTag" <%="true".equalsIgnoreCase(removeTag) ? "checked" : "" %>></label></td>
											<td><label class="checkbox"><input type="checkbox" value="true" name="_field-list_<%=i%>-multiValue" <%="true".equalsIgnoreCase(multiValue) ? "checked" : "" %>></label></td>
											<td><input type="text" class="form-control" name="_field-list_<%=i%>-multiValueDelimiter" value="<%=multiValueDelimiter %>"></td>
											<td>
												<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
												<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
											</td>
										</tr>
										<%
										}
									}
									%>
									</tbody>
								</table>
							</div>
						</div>
	
					</div>
					<!-- //fields tab -->
						
						<!-- constraints tab  -->
					<div class="col-md-12">
					
						<div class="widget">
							<div class="widget-header">
								<h4>Primary Keys</h4>
							</div>

							<div class="widget-content">
								<div>
									<table class="table table-bordered table-hover table-highlight-head table-condensed">
										<thead>
											<tr>
												<th>Field</th>
												<th class="fcol1-1"></th>
											</tr>
										</thead>
										<tbody key="_primary-key_">
										<%
										root = document.getRootElement();
										el = root.getChild("primary-key");
										if(el != null){
											List<Element> fieldList = el.getChildren();
											%>
											<tr class="no-entry <%=fieldList.size() > 0 ? "hide2" : ""%>">
												<td colspan="2"><a href="javascript:void(0)" class="addRow">Add Entry</a></td>
											</tr>
											<%
											for(int i = 0; i < fieldList.size(); i++){
												Element field = fieldList.get(i);
												String ref = field.getAttributeValue("ref");
											%>
											<tr>
												<td>
													<input type="hidden" name="KEY_NAME" value="_primary-key_<%=i %>" />
													<input type="text" name="_primary-key_<%=i%>-ref" class="fcol2 form-control" value="<%=ref %>"/>
												</td>
												<td>
													<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
													<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
												</td>
											</tr>														
											<%
											}
										}
										%>
										</tbody>
									</table>
								</div>
							</div>
						</div>
						
					</div>
					<!--//primary-key tab  -->
						
					<!-- analyzer tab  -->
					<div class="col-md-12">
					
						<div class="widget">
							<div class="widget-header">
								<h4>Analyzers</h4>
							</div>

							<div class="widget-content">
								<div>
									<table class="table table-bordered table-hover table-highlight-head table-condensed" >
										<thead>
											<tr>
												<th class="fcol2">ID</th>
												<th class="fcol1-1">Core<br>Pool Size</th>
												<th class="fcol1-1">Maximum<br>Pool Size</th>
												<th>Analyzer</th>
												<th class="fcol1-1"></th>
											</tr>
										</thead>
										<tbody key="_analyzer-list_">
										<%
										root = document.getRootElement();
										el = root.getChild("analyzer-list");
										if(el != null){
											List<Element> analyzerList = el.getChildren();
											%>
											<tr class="no-entry <%=analyzerList.size() > 0 ? "hide2" : ""%>">
												<td colspan="5"><a href="javascript:void(0)" class="addRow">Add Entry</a></td>
											</tr>
											<%
											for(int i = 0; i < analyzerList.size(); i++){
												Element analyzer = analyzerList.get(i);
												
												String id = analyzer.getAttributeValue("id");
												String corePoolSize = analyzer.getAttributeValue("corePoolSize", "");
												String maximumPoolSize = analyzer.getAttributeValue("maximumPoolSize", "");
												String analyzerClass = analyzer.getAttributeValue("className", "");
											%>
											<tr>
												<td>
													<input type="hidden" name="KEY_NAME" value="_analyzer-list_<%=i %>" />
													<input type="text" name="_analyzer-list_<%=i%>-id" class="form-control required" value="<%=id %>"></td>
												<td><input type="text" name="_analyzer-list_<%=i%>-corePoolSize" class="form-control required digits" value="<%=corePoolSize %>"></td>
												<td><input type="text" name="_analyzer-list_<%=i%>-maximumPoolSize" class="form-control required digits" value="<%=maximumPoolSize %>"></td>
												<td><input type="text" name="_analyzer-list_<%=i%>-class" class="form-control required" value="<%=analyzerClass %>"></td>
												<td>
												<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
												<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
												</td>
											</tr>
											<%
											}
										}
										%>
										</tbody>
									</table>
								</div>
							</div>
						</div>
						
					</div>
					<!--//analyzer tab  -->
						
						
					<!-- search indexes -->
					<div class="col-md-12">
					
						<div class="widget">
							<div class="widget-header">
								<h4>Search Indexes</h4>
							</div>

							<div class="widget-content">
								<table id="schema_table_search_indexes" class="table table-bordered table-hover table-highlight-head table-condensed">
									<thead>
										<tr>
											<th class="fcol2">ID</th>
											<th class="fcol2">Name</th>
											<th class="fcol2-1">Field List</th>
											<th>Index Analyzer</th>
											<th>Query Analyzer</th>
											<th class="fcol1">Ignore Case</th>
											<th class="fcol1">Store Position</th>
											<th class="fcol1">Position Increment Gap</th>
											<th class="fcol1-1"></th>
										</tr>
									</thead>
									
									<tbody key="_index-list_">
									<%
									root = document.getRootElement();
									el = root.getChild("index-list");
									if(el != null){
										List<Element> indexList = el.getChildren();
										%>
										<tr class="no-entry <%=indexList.size() > 0 ? "hide2" : ""%>">
											<td colspan="9"><a href="javascript:void(0)" class="addRow">Add Entry</a></td>
										</tr>
										<%
										for(int i = 0; i <indexList.size(); i++){
											Element field = indexList.get(i);
											List<Element> fieldList = field.getChildren("field");
											String fieldRefList = "";
											String indexAnalyzerList = "";
											for(int j = 0; j < fieldList.size(); j++){
												if(fieldRefList.length() > 0){
													fieldRefList += "\n";
													indexAnalyzerList += "\n";
												}
												Element fieldRef = fieldList.get(j);
												fieldRefList += fieldRef.getAttributeValue("ref");
												indexAnalyzerList += fieldRef.getAttributeValue("indexAnalyzer");
											}
											String id = field.getAttributeValue("id");
											String name = field.getAttributeValue("name", "");
											String queryAnalyzer = field.getAttributeValue("queryAnalyzer", "");
											String ignoreCase = field.getAttributeValue("ignoreCase", "");
											String storePosition = field.getAttributeValue("storePosition", "");
											String positionIncrementGap = field.getAttributeValue("positionIncrementGap", "");
										%>
										<tr>
											<td>
												<input type="hidden" name="KEY_NAME" value="_index-list_<%=i %>" />
												<input type="text" name="_index-list_<%=i%>-id" class="form-control required" value="<%=id %>">
											</td>
											<td><input type="text" name="_index-list_<%=i%>-name" class="form-control required" value="<%=name %>"></td>
											<td>
												<textarea name="_index-list_<%=i%>-refList" class="form-control required"><%=fieldRefList %></textarea>
											</td>
											<td>
												<textarea name="_index-list_<%=i%>-indexAnalyzer" class="form-control required"><%=indexAnalyzerList %></textarea>
											</td>
											<td><input type="text" name="_index-list_<%=i%>-queryAnalyzer" class="form-control required" value="<%=queryAnalyzer %>"></td>
											<td><label class="checkbox"><input type="checkbox" value="true" name="_index-list_<%=i%>-ignoreCase" <%="true".equalsIgnoreCase(ignoreCase) ? "checked" : "" %>></label></td>
											<td><label class="checkbox"><input type="checkbox" value="true" name="_index-list_<%=i%>-storePosition" <%="true".equalsIgnoreCase(storePosition) ? "checked" : "" %>></label></td>
											<td><input type="text" name="_index-list_<%=i%>-pig" class="form-control digits" value="<%=positionIncrementGap %>"></td>
											<td>
												<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
												<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
											</td>
										</tr>														
										<%
										}
									}
									%>
									</tbody>
								</table>
							</div>
						</div>
					</div>
					<!-- //search-index-list -->
						
						
					<!-- field-index-list tab  -->
					<div class="col-md-12">
					
						<div class="widget">
							<div class="widget-header">
								<h4>Field Indexes</h4>
							</div>

							<div class="widget-content">
								<table class="table table-bordered table-hover table-highlight-head table-condensed">
									<thead>
										<tr>
											<th class="fcol2">ID</th>
											<th>Name</th>
											<th class="fcol2">Field</th>
											<th class="fcol2">Size</th>
											<th class="fcol1-1"></th>
										</tr>
									</thead>
									<tbody key="_field-index-list_">
									<%
									root = document.getRootElement();
									el = root.getChild("field-index-list");
									if(el != null){
										List<Element> indexList = el.getChildren();
										%>
										<tr class="no-entry <%=indexList.size() > 0 ? "hide2" : ""%>">
											<td colspan="5"><a href="javascript:void(0)" class="addRow">Add Entry</a></td>
										</tr>
										<%
										for(int i = 0; i < indexList.size(); i++){
											Element fieldIndex = indexList.get(i);
											
											String id = fieldIndex.getAttributeValue("id");
											String name = fieldIndex.getAttributeValue("name", "");
											String ref = fieldIndex.getAttributeValue("ref", "");
											String size = fieldIndex.getAttributeValue("size", "");
										%>
										<tr>
											<td>
												<input type="hidden" name="KEY_NAME" value="_field-index-list_<%=i %>" />
												
												<input type="text" name="_field-index-list_<%=i%>-id" class="form-control" value="<%=id %>"></td>
											<td><input type="text" name="_field-index-list_<%=i%>-name" class="form-control" value="<%=name %>"></td>
											<td><input type="text" name="_field-index-list_<%=i%>-field" class="form-control" value="<%=ref %>"></td>
											<td><input type="text" name="_field-index-list_<%=i%>-size" class="form-control digits fcol1-1" value="<%=size %>"></td>
											<td>
												<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
												<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
											</td>
										</tr>														
										<%
										}
									}
									%>
									</tbody>
								</table>
							</div>
						</div>
					</div>
					<!--//field_indexes tab  -->
						
						
					<!-- group_indexes tab  -->
					<div class="col-md-12">
					
						<div class="widget">
							<div class="widget-header">
								<h4>Group Indexes</h4>
							</div>
							<div class="widget-content">
								<div>
									<table class="table table-bordered table-hover table-highlight-head table-condensed">
										<thead>
											<tr>
												<th class="fcol2">ID</th>
												<th>Name</th>
												<th class="fcol2">Field</th>
												<th class="fcol1-1"></th>
											</tr>
										</thead>
										<tbody key="_group-index-list_">
										<%
										root = document.getRootElement();
										el = root.getChild("group-index-list");
										if(el != null){
											List<Element> indexList = el.getChildren();
											%>
											<tr class="no-entry <%=indexList.size() > 0 ? "hide2" : ""%>">
												<td colspan="4"><a href="javascript:void(0)" class="addRow">Add Entry</a></td>
											</tr>
											<%
											for(int i = 0; i<indexList.size(); i++){
												String id="", name="", ref="";
												if(indexList.size() > 0) {
													Element groupIndex = indexList.get(i);
													id = groupIndex.getAttributeValue("id");
													name = groupIndex.getAttributeValue("name", "");
													ref = groupIndex.getAttributeValue("ref", "");
												}
											%>
											<tr>
												<td>
													<input type="hidden" name="KEY_NAME" value="_group-index-list_<%=i %>" />
													<input type="text" name="_group-index-list_<%=i%>-id" class="form-control" value="<%=id %>"></td>
												<td><input type="text" name="_group-index-list_<%=i%>-name" class="form-control" value="<%=name %>"></td>
												<td><input type="text" name="_group-index-list_<%=i%>-ref" class="form-control" value="<%=ref %>"></td>
												<td>
													<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
													<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
												</td>
											</tr>														
											<%
											}
										}
										%>
										</tbody>
									</table>
								</div>
							</div>
						</div>
							
					</div>
					<!--//group-index-list tab  -->
						
				</form>

				<!-- /Page Content -->
				
				
			</div>
		</div>
	</div>
	
	
	<div>
	<!-- template list -->
	<table id="schema_template" class="hidden">
		<tr key="_field-list_">
			<td>
				<input type="hidden" name="KEY_NAME" />
				<input type="text" name="id" class="form-control required">
			</td>
			<td><input type="text" name="name" class="form-control required"></td>
			<td><select class="select_flat form-control required select-field-type" name="type" >
				<option value="">:: Type ::</option>
			<%
			for(int typeInx=0;typeInx < typeList.length(); typeInx++) { 
				String typeStr = typeList.optString(typeInx);
			%>
			<option value="<%=typeStr %>"><%=typeStr %></option>
			<%
			}
			%>
			</select></td>
			<td><input type="text" name="size" class="form-control field-type-size digit"></td>
			<td><label class="checkbox"><input type="checkbox" value="true" name="store" checked></label></td>
			<td><label class="checkbox"><input type="checkbox" value="true" name="removeTag"></label></td>
			<td><label class="checkbox"><input type="checkbox" value="true" name="multiValue"></label></td>
			<td><input type="text" class="form-control" name="multiValueDelimiter"></td>
			<td>
				<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
				<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
			</td>
		</tr>
										
		<tr key="_primary-key_">
			<td>
				<input type="hidden" name="KEY_NAME" />
				<input type="text" name="ref" class="fcol2 form-control"/>
			</td>
			<td>
				<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
				<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
			</td>
		</tr>
		
		<tr key="_analyzer-list_">
			<td>
				<input type="hidden" name="KEY_NAME" />
				<input type="text" name="id" class="form-control required"></td>
			<td><input type="text" name="corePoolSize" class="form-control required digits"></td>
			<td><input type="text" name="maximumPoolSize" class="form-control required digits"></td>
			<td><input type="text" name="class" class="form-control required"></td>
			<td>
				<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
				<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
			</td>
		</tr>
		
		<tr key="_index-list_">
			<td>
				<input type="hidden" name="KEY_NAME"/>
				<input type="text" name="id" class="form-control required"></td>
			<td><input type="text" name="name" class="form-control required"></td>
			<td><textarea name="refList" class="form-control required"></textarea></td>
			<td><textarea name="indexAnalyzer" class="form-control required"></textarea></td>
			<td><input type="text" name="queryAnalyzer" class="form-control required"></td>
			<td ><label class="checkbox"><input type="checkbox" value="true" name="ignoreCase"></label></td>
			<td ><label class="checkbox"><input type="checkbox" value="true" name="storePosition"></label></td>
			<td ><input type="text" name="pig" class="form-control digits"></td>
			<td>
				<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
				<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
			</td>
		</tr>
		
		<tr key="_field-index-list_">
			<td>
				<input type="hidden" name="KEY_NAME"/>
				<input type="text" name="id" class="form-control"></td>
			<td><input type="text" name="name" class="form-control"></td>
			<td><input type="text" name="field" class="form-control"></td>
			<td><input type="text" name="size" class="form-control digits fcol1-1"></td>
			<td>
				<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
				<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
			</td>
		</tr>
		
		<tr key="_group-index-list_">
			<td>
				<input type="hidden" name="KEY_NAME" />
				<input type="text" name="id" class="form-control"></td>
			<td><input type="text" name="name" class="form-control"></td>
			<td><input type="text" name="ref" class="form-control"></td>
			<td>
				<span><a class="btn btn-xs addRow" href="javascript:void(0);"><i class="icon-plus-sign"></i></a></span>
				<span><a class="btn btn-xs deleteRow" href="javascript:void(0);" style="margin-left:5px;"><i class="icon-minus-sign text-danger"></i></a></span>
			</td>
		</tr>
	</table>
	<!-- // template list -->
	</div>
	
</body>
</html>