package org.fastcatsearch.console.web;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.fastcatsearch.console.web.http.ResponseHttpClient;
import org.json.JSONObject;

public class AuthManagerInterceptor extends AuthMainInterceptor {
	
	@Override
	public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
		if(!super.preHandle(request, response, handler)){
			return false;
		}
		ResponseHttpClient httpClient = (ResponseHttpClient) request.getSession().getAttribute("httpclient");
		String getCollectionListURL = "/management/collections/collection-list";
		JSONObject collectionList = httpClient.httpGet(getCollectionListURL).requestJSON();
		request.setAttribute("collectionList", collectionList.getJSONArray("collectionList"));
		
		String getAnalysisPluginListURL = "/management/analysis/plugin-list";
		JSONObject analysisPluginList = httpClient.httpGet(getAnalysisPluginListURL).requestJSON();
		request.setAttribute("analysisPluginList", analysisPluginList.getJSONArray("pluginList"));
		
		return true;
	}
}