<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>

<%@page import="org.json.*"%>
<%
	String dictionaryId = (String) request.getAttribute("dictionaryId");
	String dictionaryOption = (String) request.getAttribute("dictionaryOption");
	JSONObject list = (JSONObject) request.getAttribute("list");
	int totalSize = list.getInt("totalSize");
	int filteredSize = list.getInt("filteredSize");
	JSONArray entryList = (JSONArray) list.getJSONArray(dictionaryId);
	int start = (Integer) request.getAttribute("start");
	String targetId = (String) request.getAttribute("targetId");
	JSONArray searchableColumnList = (JSONArray) list.getJSONArray("searchableColumnList");
	String searchColumn = (String) request.getAttribute("searchColumn");
	boolean is2Way = "2WAY".equals(dictionaryOption);
%>
<script>

var searchInputObj;
var searchColumnObj;
var exactMatchObj;

$(document).ready(function(){
	
	searchInputObj = $("#search_input_${dictionaryId}");
	searchColumnObj = $("#${dictionaryId}SearchColumn");
	exactMatchObj = $("#${dictionaryId}ExactMatch");
	
	searchInputObj.keydown(function (e) {
		if(e.keyCode == 13){
			var keyword = toSafeString($(this).val());
			loadDictionaryTab("${dictionaryType}", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), false, '<%=targetId%>');
			return;
		}
	});
	searchInputObj.focus();
	
	searchColumnObj.on("change", function(){
		var keyword = toSafeString(searchInputObj.val());
		if(keyword != ""){
			loadDictionaryTab("${dictionaryType}", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), false, '<%=targetId%>');
		}
	});
	exactMatchObj.on("change", function(){
		var keyword = toSafeString(searchInputObj.val());
		if(keyword != ""){
			loadDictionaryTab("${dictionaryType}", '<%=dictionaryId %>', 1, keyword, searchColumnObj.val(), exactMatchObj.is(":checked"), false, '<%=targetId%>');
		}
	});
});

function go<%=dictionaryId%>DictionaryPage(uri, pageNo){
	loadDictionaryTab("${dictionaryType}", '<%=dictionaryId %>', pageNo, '${keyword}', searchColumnObj.val(), exactMatchObj.is(":checked"), false, '<%=targetId%>');	
}
function go<%=dictionaryId%>EditablePage(pageNo){
	loadDictionaryTab("${dictionaryType}", '<%=dictionaryId %>', pageNo, '${keyword}', searchColumnObj.val(), exactMatchObj.is(":checked"), true, '<%=targetId%>');	
}
</script>

<div class="col-md-12">
<div class="widget box">
	<div class="widget-content no-padding">
		<div class="dataTables_header clearfix">
			<div class="form-inline col-md-7">
				<%
				if(is2Way){
				%>
					<input type="hidden" id="<%=dictionaryId %>SearchColumn" value="_ALL" />
				<% }else{ %>
				<div class="form-group">
					<select id="<%=dictionaryId %>SearchColumn" class="select_flat form-control">
						<option value="_ALL">ALL</option>
						<%
						for(int i=0; i < searchableColumnList.length(); i++){
							String columnName = searchableColumnList.getString(i);
						%>
						<option value="<%=columnName %>" <%=(columnName.equals(searchColumn)) ? "selected" : "" %>><%=columnName %></option>
						<%
						}
						 %>
					</select>
				</div>
				<%
				}
				%>
				<div class="form-group " style="width:240px">
			        <div class="input-group" >
			            <span class="input-group-addon"><i class="icon-search"></i></span>
			            <input type="text" class="form-control" placeholder="Search" id="search_input_<%=dictionaryId%>" value="${keyword}">
			        </div>
			    </div>
			    <div class="form-group">
			    	&nbsp;
			    	<div class="checkbox">
			    	<label>
			    		<input type="checkbox" id="<%=dictionaryId %>ExactMatch" <c:if test="${exactMatch}">checked</c:if>> Exact Match
			    	</label>
			    	</div>
			    </div>
			</div>
				
			<div class="col-md-5">
				<div class="pull-right">
					<a href="javascript:downloadDictionary('synonym', '<%=dictionaryId%>')"  class="btn btn-default btn-sm">
						<span class="icon icon-download"></span> Download
					</a>
					&nbsp;
					<div class="btn-group">
						<a href="javascript:go<%=dictionaryId%>DictionaryPage('', '${pageNo}');" class="btn btn-sm" rel="tooltip"><i class="icon-refresh"></i></a>
					</div>
					&nbsp;
					<a href="javascript:go<%=dictionaryId%>EditablePage('${pageNo}');"  class="btn btn-default btn-sm">
						<span class="glyphicon glyphicon-edit"></span> Edit
					</a>
				</div>
			</div>
		</div>
		
		<%
		if(entryList.length() > 0){
		%>
		<div class="col-md-12" style="overflow:auto">
		
			<table class="table table-hover table-bordered">
				<thead>
					<tr>
						<%
						if(!is2Way){
						%>
						<th>Keyword</th>
						<%
						}
						%>
						<th>Synonym words</th>
					</tr>
				</thead>
				<tbody>
					
				<%
				for(int i=0; i < entryList.length(); i++){
					JSONObject obj = entryList.getJSONObject(i);
				%>
					<tr>
						<%
						//is2Way 이면 표시하지 않는다.
						if(!is2Way){
						%>
						<td class="col-md-2"><%=obj.getString("KEYWORD") %></td>
						<%
						}
						%>
						<td><%=obj.getString("SYNONYM") %></td>
					</tr>
					
				<%
				}
				%>
				</tbody>
			</table>
		</div>
		<%
		}
		%>
		<div class="table-footer">
			<div class="col-md-12">
			Rows 
			<% if(entryList.length() > 0) { %>
			<%=start %> - <%=start + entryList.length() - 1 %> of <%=filteredSize %> <% if(filteredSize != totalSize) {%> (filtered from <%=totalSize %> total entries)<% } %>
			<% } else { %>
			Empty
			<% } %>
			
			<jsp:include page="../../inc/pagenation.jsp" >
			 	<jsp:param name="pageNo" value="${pageNo }"/>
			 	<jsp:param name="totalSize" value="<%=filteredSize %>" />
				<jsp:param name="pageSize" value="${pageSize }" />
				<jsp:param name="width" value="5" />
				<jsp:param name="callback" value="go${dictionaryId }DictionaryPage" />
				<jsp:param name="requestURI" value="" />
			 </jsp:include>
			</div>
		</div>	
	</div>
</div>
</div>