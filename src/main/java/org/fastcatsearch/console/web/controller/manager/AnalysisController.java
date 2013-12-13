package org.fastcatsearch.console.web.controller.manager;

import javax.servlet.http.HttpSession;

import org.apache.http.client.ClientProtocolException;
import org.fastcatsearch.console.web.controller.AbstractController;
import org.fastcatsearch.console.web.http.Http404Error;
import org.fastcatsearch.console.web.http.ResponseHttpClient;
import org.jdom2.Document;
import org.jdom2.Element;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/manager/analysis")
public class AnalysisController extends AbstractController {
	private static Logger logger = LoggerFactory.getLogger(AnalysisController.class);

	private static JSONObject AnalyzeToolsDetailNotImplementedResult;
	
	static {
		AnalyzeToolsDetailNotImplementedResult = new JSONObject();
		AnalyzeToolsDetailNotImplementedResult.put("success", false);
		AnalyzeToolsDetailNotImplementedResult.put("errorMessage", "This plugin does not provide DetailAnalyzeTools.");
	}
	
	@RequestMapping("/plugin")
	public ModelAndView plugin(HttpSession session) throws Exception {
		ResponseHttpClient httpClient = (ResponseHttpClient) session.getAttribute("httpclient");
		String getAnalysisPluginListURL = "/management/analysis/plugin-list";
		JSONObject jsonObj = httpClient.httpGet(getAnalysisPluginListURL).requestJSON();
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/analysis/plugin");
		mav.addObject("analysisPluginOverview", jsonObj.getJSONArray("pluginList"));
		return mav;
	}

	@RequestMapping("/{analysisId}/index")
	public ModelAndView view(HttpSession session, @PathVariable String analysisId) throws Exception {
		
		ResponseHttpClient httpClient = (ResponseHttpClient) session.getAttribute("httpclient");
		String getAnalysisPluginSettingURL = "/management/analysis/plugin-setting.xml";
		Document document = httpClient.httpGet(getAnalysisPluginSettingURL).addParameter("pluginId", analysisId).requestXML();
		Element rootElement = document.getRootElement();
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/analysis/index");
		mav.addObject("analysisId", analysisId);
		mav.addObject("setting",rootElement);
		logger.debug("rootElement >> {}", rootElement);
		return mav;
	}
	
	
	
	@RequestMapping("/{analysisId}/analyzeTools")
	public ModelAndView analyzeTools(HttpSession session, @PathVariable String analysisId, @RequestParam String type, @RequestParam String queryWords) throws Exception {
		
		ResponseHttpClient httpClient = (ResponseHttpClient) session.getAttribute("httpclient");
		
		String getAnalysisToolsURL = null;
		
		JSONObject jsonObj = null;
		
		if("detail".equalsIgnoreCase(type)){
			getAnalysisToolsURL = "/_plugin/"+analysisId+"/analysis-tools-detail.json";
			try{
				jsonObj = httpClient.httpPost(getAnalysisToolsURL).addParameter("queryWords", queryWords).requestJSON();
			}catch(ClientProtocolException e){
				jsonObj = AnalyzeToolsDetailNotImplementedResult;
				jsonObj.put("query", queryWords);
			}
		}else{
			getAnalysisToolsURL = "/management/analysis/analysis-tools.json";
			jsonObj = httpClient.httpPost(getAnalysisToolsURL)
					.addParameter("pluginId", analysisId)
					.addParameter("queryWords", queryWords).requestJSON();
		}
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/analysis/analyzeTools");
		mav.addObject("analyzedResult", jsonObj);
		return mav;
	}
}
