<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@page import="
org.json.JSONObject,
org.json.JSONArray
"%>
<script>
function goExceptionDataRawPage(url, pageNo) {
	loadExceptionTab(pageNo, "#tab_message_list");
}
function loadMessage(obj) {
	$('#exception_detail').show();
	$('#exception_detail').find("._time").text($(obj).find("._time").text());
	$('#exception_detail').find("._node").text($(obj).find("._node").text());
	$('#exception_detail').find("._message").text($(obj).find("._message").text());
	$('#exception_detail').find("._trace").text($(obj).find("._trace").text());
}
$(document).ready(function(){
	$('#exception_detail').hide();
	$("._row").css("cursor","pointer");
});
</script>

<%
int start = (Integer)request.getAttribute("start");
int end = (Integer)request.getAttribute("end");
int pageNo = (Integer)request.getAttribute("pageNo");
int pageSize = (Integer)request.getAttribute("pageSize");
int totalCount = 0;

	JSONArray exceptionList = null;

	JSONObject exceptions = (JSONObject)request.getAttribute("exceptions");
	exceptionList = exceptions.optJSONArray("exceptions");
	totalCount = exceptions.optInt("totalCount", 0);

%>
<div class="col-md-12">
<div class="widget box">
	<div class="widget-content no-padding">
		<div class="dataTables_header clearfix">
			<div class="col-md-7 form-inline">
				<%
				if(exceptionList.length() > 0){
				%>
					<span>Rows ${start} - ${end} of <%=totalCount%></span>
				<%
				}else{
				%>
					<span>Rows 0</span>
				<%
				}
				%>
			</div>
			<div class="col-md-12">
				<div class="btn-group pull-right">
					<jsp:include page="../../inc/pagenationTop.jsp" >
					 	<jsp:param name="pageNo" value="${pageNo }"/>
					 	<jsp:param name="totalSize" value="<%=totalCount %>" />
						<jsp:param name="pageSize" value="${pageSize }" />
						<jsp:param name="width" value="5" />
						<jsp:param name="callback" value="goExceptionDataRawPage" />
						<jsp:param name="requestURI" value="" />
					 </jsp:include>
				</div>
			</div>
		</div>
		<table id="log_table" class="table table-hover table-bordered table-condensed table-checkable">
			<thead>
				<tr>
					<th>#</th>
					<th>Time</th>
					<th>Node</th>
					<th>Message</th>
				</tr>
			</thead>
			<tbody>
			<%
			if(exceptionList!=null && exceptionList.length() > 0) {
			%>
				<%
				for(int inx=0;inx < exceptionList.length(); inx++) {
				%>
					<%
					JSONObject record = exceptionList.optJSONObject(inx);
					%>
					<tr class="_row" onclick="loadMessage(this)">
						<td><%=record.optInt("id") %></td>
						<td class="_time"><%=record.optString("regtime") %></td>
						<td class="_node"><%=record.optString("node") %></td>
						<td class="_message"><%=record.optString("message") %></td>
						<td class="_trace hide"><%=record.optString("trace") %></td>
					</tr>
				<%
				}
				%>
			<%
			} else {
			%>
				<tr>
					<td colspan="5">Empty row</td>
				</tr>
			<%
			}
			%>
			</tbody>
		</table>
		<div class="table-footer" id="exception_detail">
			<dl class="dl-horizontal col-md-12" >
				<dt>Time</dt>
				<dd class="_time"></dd>
				<dt>Node</dt>
				<dd class="_node"></dd>
				<dt>Message</dt>
				<dd class="_message"></dd>
				<dt>Trace</dt>
				<dd><div class="panel _trace"></div></dd>
			</dl>
		</div>
	</div>
</div>
</div>