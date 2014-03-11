package org.fastcatsearch.console.web.controller.manager;

import java.util.Enumeration;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.fastcatsearch.console.web.controller.AbstractController;
import org.fastcatsearch.console.web.http.ResponseHttpClient;
import org.fastcatsearch.console.web.http.ResponseHttpClient.PostMethod;
import org.jdom2.Document;
import org.jdom2.Element;
import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/manager/collections")
public class CollectionsController extends AbstractController {

	@RequestMapping("/index")
	public ModelAndView index(HttpSession session) throws Exception {
		String requestUrl = "/management/collections/collection-info-list.json";
		JSONObject collectionInfoList = httpPost(session, requestUrl).requestJSON();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/index");
		if(collectionInfoList != null){
			mav.addObject("collectionInfoList", collectionInfoList.optJSONArray("collectionInfoList"));
		}
		return mav;
	}
	
	@RequestMapping("/{collectionId}/schema")
	public ModelAndView schema(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/schema.xml";
		Document document = httpPost(session, requestUrl).addParameter("collectionId", collectionId).requestXML();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/schema");
		mav.addObject("collectionId", collectionId);
		mav.addObject("document", document);
		mav.addObject("schemaType", "schema");
		return mav;
	}

	@RequestMapping("/{collectionId}/workSchema")
	public ModelAndView workSchemaView(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/schema.xml";
		Document document = httpPost(session, requestUrl).addParameter("collectionId", collectionId).addParameter("type", "workSchema").requestXML();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/schema");
		mav.addObject("collectionId", collectionId);
		mav.addObject("document", document);
		mav.addObject("schemaType", "workSchema");
		return mav;
	}

	@RequestMapping("/{collectionId}/workSchemaEdit")
	public ModelAndView workSchemaEdit(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/schema.xml";
		Document document = httpPost(session, requestUrl).addParameter("collectionId", collectionId).addParameter("type", "workSchema").addParameter("mode", "copyCurrentSchema")
				.requestXML();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/schemaEdit");
		mav.addObject("collectionId", collectionId);
		mav.addObject("document", document);
		mav.addObject("schemaType", "workSchema");
		return mav;
	}

	@RequestMapping("/{collectionId}/workSchemaSave")
	@ResponseBody
	public String workSchemaSave(HttpSession session, HttpServletRequest request, @PathVariable String collectionId) throws Exception {

		// 화면의 저장 값들을 재조정하여 json으로 만든후 서버로 보낸다.

		JSONObject root = new JSONObject();
		
		String name = null;
		String key = null;
		String paramKey = null;
		String value = null;
		String validationLevel = request.getParameter("validationLevel");
		int keyIndex = 0;
		
		@SuppressWarnings("unchecked")
		Enumeration<String> keyEnum = request.getParameterNames();
		
		Pattern pattern = Pattern.compile("^_([a-zA-Z_-]+)_([0-9]+)-([a-zA-Z]+)$");
		Matcher matcher;
		
		while (keyEnum.hasMoreElements()) {
			paramKey = keyEnum.nextElement();
			matcher = pattern.matcher(paramKey);
			
			if(matcher.find()) {
				key = matcher.group(1);
				keyIndex = Integer.parseInt(matcher.group(2));
				name = matcher.group(3);
				value = request.getParameter(paramKey);
				JSONObject item = getIndexedItemMap(root, key, keyIndex);
				if(item!=null) {
					item.put(name, value);
				}
			}
		}
		
		String jsonSchemaString = root.toString();
		logger.debug("jsonSchemaString > {}", jsonSchemaString);

		String requestUrl = "/management/collections/schema/update.json";
		JSONObject object = httpPost(session, requestUrl).addParameter("collectionId", collectionId)
				.addParameter("type", "workSchema") //work schema를 업데이트한다.
				.addParameter("validationLevel", validationLevel)
				.addParameter("schemaObject", jsonSchemaString).requestJSON();

		if (object != null) {
			return object.toString();
		} else {
			return "{}";
		}
	}
	
	private JSONObject getIndexedItemMap(JSONObject parent, String key, int putInx) {
		JSONObject ret = null;
		JSONArray array = parent.optJSONArray(key);
		if(array == null) {
			array = new JSONArray();
			parent.put(key, array);
		}
		
		for(int inx=array.length() ;inx <= putInx; inx++) {
			array.put(inx, new JSONObject());
		}
		return array.getJSONObject(putInx);
	}

	@RequestMapping("/{collectionId}/data")
	public ModelAndView data(HttpSession session, @PathVariable String collectionId) throws Exception {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/data");
		mav.addObject("collectionId", collectionId);
		return mav;
	}

	@RequestMapping("/{collectionId}/dataRaw")
	public ModelAndView dataRaw(HttpSession session, @PathVariable String collectionId, @RequestParam(defaultValue = "1") Integer pageNo, @RequestParam String targetId)
			throws Exception {

		int PAGE_SIZE = 10;
		int start = 0;
		int end = 0;

		if (pageNo > 0) {
			start = (pageNo - 1) * PAGE_SIZE;
			end = start + PAGE_SIZE - 1;
		}

		String requestUrl = "/management/collections/index-data.json";
		JSONObject indexData = httpGet(session, requestUrl).addParameter("collectionId", collectionId).addParameter("start", String.valueOf(start))
				.addParameter("end", String.valueOf(end)).requestJSON();
		JSONArray list = indexData.getJSONArray("indexData");
		int realSize = list.length();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/dataRaw");
		mav.addObject("collectionId", collectionId);
		mav.addObject("start", start + 1);
		mav.addObject("end", start + realSize);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("indexDataResult", indexData);
		mav.addObject("targetId", targetId);
		return mav;
	}
	
	@RequestMapping("/{collectionId}/dataAnalyzed")
	public ModelAndView dataAnalyzed(HttpSession session, @PathVariable String collectionId, @RequestParam(defaultValue = "1") Integer pageNo, @RequestParam String targetId)
			throws Exception {

		int PAGE_SIZE = 10;
		int start = 0;
		int end = 0;

		if (pageNo > 0) {
			start = (pageNo - 1) * PAGE_SIZE;
			end = start + PAGE_SIZE - 1;
		}

		String requestUrl = "/management/collections/index-data-analyzed.json";
		JSONObject indexData = httpGet(session, requestUrl).addParameter("collectionId", collectionId).addParameter("start", String.valueOf(start))
				.addParameter("end", String.valueOf(end)).requestJSON();
		JSONArray list = indexData.getJSONArray("indexData");
		int realSize = list.length();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/dataAnalyzed");
		mav.addObject("collectionId", collectionId);
		mav.addObject("start", start + 1);
		mav.addObject("end", start + realSize);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("indexDataResult", indexData);
		mav.addObject("targetId", targetId);
		return mav;
	}

	@RequestMapping("/{collectionId}/dataSearch")
	public ModelAndView dataSearch(HttpSession session, @PathVariable String collectionId, @RequestParam(value = "se", required = false) String se,
			@RequestParam(value = "ft", required = false) String ft, @RequestParam(value = "gr", required = false) String gr, @RequestParam(defaultValue = "1") Integer pageNo,
			@RequestParam String targetId) throws Exception {

		int PAGE_SIZE = 10;
		int start = (pageNo - 1) * PAGE_SIZE + 1;

		String requestUrl = "/management/collections/index-data-status.json";
		JSONObject indexDataStatus = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
		logger.debug("indexDataStatus >> {}", indexDataStatus);

		requestUrl = "/service/search.json";
		JSONObject searchResult = httpGet(session, requestUrl).addParameter("cn", collectionId).addParameter("fl", "Title")
				// FIXME
				.addParameter("se", se).addParameter("ft", ft).addParameter("gr", gr).addParameter("sn", String.valueOf(start)).addParameter("ln", String.valueOf(PAGE_SIZE))
				.requestJSON();
		logger.debug("searchResult >> {}", searchResult);
		JSONArray list = searchResult.getJSONArray("result");
		int realSize = list.length();
		// TODO group_result.group_list

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/dataSearch");
		mav.addObject("collectionId", collectionId);
		mav.addObject("start", start);
		mav.addObject("end", start + realSize - 1);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("searchResult", searchResult);
		mav.addObject("indexDataStatus", indexDataStatus);
		mav.addObject("targetId", targetId);
		return mav;
	}

	@RequestMapping("/{collectionId}/datasource")
	public ModelAndView datasource(HttpSession session, @PathVariable String collectionId) throws Exception {
		ResponseHttpClient httpClient = (ResponseHttpClient) session.getAttribute("httpclient");
		String requestUrl = "/management/collections/datasource.xml";
		Document document = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestXML();

		requestUrl = "/management/collections/jdbc-source.xml";
		Document documentJDBC = httpGet(session, requestUrl).requestXML();
		
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/datasource");
		mav.addObject("collectionId", collectionId);
		mav.addObject("document", document);
		mav.addObject("jdbcSource", documentJDBC);
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing")
	public ModelAndView indexing(HttpSession session, @PathVariable String collectionId) throws Exception {

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexing");
		mav.addObject("collectionId", collectionId);
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing/status")
	public ModelAndView indexingStatus(HttpSession session, @PathVariable String collectionId) throws Exception {

		String requestUrl = "/management/collections/all-node-indexing-status.json";
		JSONObject indexingStatus = null;
		try {
			indexingStatus = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
		} catch (Exception e) {
			logger.error("", e);
		}
		logger.debug("indexingStatus >> {}", indexingStatus);

		requestUrl = "/management/collections/indexing-result.json";
		JSONObject indexingResult = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
		logger.debug("indexingResult >> {}", indexingResult);

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexingStatus");
		mav.addObject("collectionId", collectionId);
		mav.addObject("indexingStatus", indexingStatus);
		mav.addObject("indexingResult", indexingResult.getJSONObject("indexingResult"));
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing/schedule")
	public ModelAndView indexingSchedule(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/indexing-schedule.xml";
		Document indexingSchedule = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestXML();
		logger.debug("indexingSchedule >> {}", indexingSchedule);

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexingSchedule");
		mav.addObject("collectionId", collectionId);
		mav.addObject("indexingSchedule", indexingSchedule);
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing/history")
	public ModelAndView indexingHistory(HttpSession session, @PathVariable String collectionId, @RequestParam(defaultValue = "1") Integer pageNo) throws Exception {

		int PAGE_SIZE = 10;
		int start = 0;
		int end = 0;

		if (pageNo > 0) {
			start = (pageNo - 1) * PAGE_SIZE + 1;
			end = start + PAGE_SIZE - 1;
		}

		String requestUrl = "/management/collections/indexing-history.json";
		JSONObject jsonObj = httpPost(session, requestUrl).addParameter("collectionId", collectionId).addParameter("start", String.valueOf(start))
				.addParameter("end", String.valueOf(end)).requestJSON();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexingHistory");
		mav.addObject("collectionId", collectionId);
		mav.addObject("start", start);
		mav.addObject("pageNo", pageNo);
		mav.addObject("pageSize", PAGE_SIZE);
		mav.addObject("list", jsonObj);
		return mav;
	}

	@RequestMapping("/{collectionId}/indexing/management")
	public ModelAndView indexingManagement(HttpSession session, @PathVariable String collectionId) throws Exception {

		String requestUrl = "/management/collections/all-node-indexing-management-status.json";
		JSONObject indexingManagementStatus = null;
		try {
			indexingManagementStatus = httpGet(session, requestUrl).addParameter("collectionId", collectionId).requestJSON();
		} catch (Exception e) {
			logger.error("", e);
		}
		logger.debug("indexingManagementStatus >> {}", indexingManagementStatus);

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/indexingManagement");
		mav.addObject("collectionId", collectionId);
		mav.addObject("indexingManagementStatus", indexingManagementStatus);
		return mav;
	}
	
	@RequestMapping("/{collectionId}/config")
	public ModelAndView settings(HttpSession session, @PathVariable String collectionId) throws Exception {
		String requestUrl = "/management/collections/config.xml";
		Document document = httpPost(session, requestUrl).addParameter("collectionId", collectionId).requestXML();

		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/collections/config");
		mav.addObject("collectionId", collectionId);
		mav.addObject("document", document);
		return mav;
	}
	
	
	@RequestMapping("/createCollectionWizard")
	public ModelAndView createCollectionWizard(HttpSession session, 
			//파라메터가 동적일 수 있으므로 부득이하게 request 객체를 사용
			HttpServletRequest request, 
			@RequestParam(required=false, defaultValue="1") String step, 
			@RequestParam(required=false, defaultValue="") String next) {
		ModelAndView mav = new ModelAndView();
		String requestUrl = null;
		JSONObject collectionInfoList = null;
		
		String collectionId = request.getParameter("collectionId");
		String collectionTmp = null;
		if(collectionId!=null) {
				collectionTmp = "."+collectionId+".tmp";
		}
		
		logger.debug("step:{} / next:{} / collectionId:{} / collectionTmp:{}", step, next, collectionId, collectionTmp);
		
		//페이지 변경사항 저장.
		try {
			if(next.equals("next")){
				if(step.equals("1")){
					requestUrl = "/management/collections/collection-info-list.json";
					collectionInfoList = httpPost(session, requestUrl).requestJSON();
					JSONArray collectionList = collectionInfoList.optJSONArray("collectionInfoList");
					boolean found = false;
					
					for (int inx = 0; inx < collectionList.length(); inx++) {
						JSONObject item = collectionList.optJSONObject(inx);
						if(item.getString("id").equals(collectionTmp)) {
							found = true;
							break;
						}
					}
					
					//만약 같은 이름의 컬렉션이 있는 경우. 허용불가.
					//차후 엔진 재시작하여 임시 컬렉션 삭제.
					if(!found) {
						logger.debug("creating collection..");
						if(collectionId != null && !"".equals(collectionId)) {
							requestUrl = "/management/collections/create.json";
							
							String collectionName = request.getParameter("collectionName");
							String indexNode = request.getParameter("indexNode");
							String searchNodeList = request.getParameter("searchNodeList");
							String dataNodeList = request.getParameter("dataNodeList");
							
							collectionInfoList = httpPost(session, requestUrl)
								.addParameter("collectionId", collectionTmp)
								.addParameter("name", collectionName)
								.addParameter("indexNode", indexNode)
								.addParameter("searchNodeList", searchNodeList)
								.addParameter("dataNodeList", dataNodeList)
								.requestJSON();
							mav.setViewName("manager/collections/create");
						}
					}
					
					step = "2";
				}else if(step.equals("2")){
					
					requestUrl = "/management/collections/datasource.xml";
					Document datasource = httpPost(session, requestUrl)
						.addParameter("collectionId", collectionTmp).requestXML();
					Element root = datasource.getRootElement();
					Element source = root.getChild("full-indexing");
					
					//데이터소스 저장.
					requestUrl = "/management/collections/update-datasource.json";
					PostMethod httpPost = httpPost(session, requestUrl);
					Enumeration<String> parameterNames = request.getParameterNames();
					httpPost.addParameter("collectionId", collectionTmp)
						.addParameter("indexType", "full")
						.addParameter("active", "false");
					if(source.getChildren().size() > 0) {
						httpPost.addParameter("sourceIndex", "0");
					}
					
					for(;parameterNames.hasMoreElements();) {
						String parameterName = parameterNames.nextElement();
						//중복되는 파라메터는 제거해 준다.
						if("collectionId".equals(parameterName)
							||"indexType".equals(parameterName)	
							||"active".equals(parameterName) ) {
							continue;
						}
						httpPost.addParameter(parameterName, request.getParameter(parameterName));
					}
					JSONObject result = httpPost.requestJSON();
					
					//워크스키마 자동생성. 
					requestUrl = "/management/collections/schema/update.json";
					httpPost = httpPost(session, requestUrl);
					httpPost.addParameter("collectionId", collectionTmp)
						.addParameter("autoSchema", "y");
					result = httpPost.requestJSON();
					
					step = "3";
				} else if(step.equals("3")){
					workSchemaSave(session, request, collectionTmp);
					
					requestUrl = "/management/collections/collection-info-list.json";
					JSONObject collectionInfo = httpPost(session, requestUrl).requestJSON();
					mav.addObject("collectionInfo",collectionInfo);
					
					requestUrl = "/management/collections/datasource.xml";
					Document datasource = httpPost(session, requestUrl)
						.addParameter("collectionId", collectionTmp).requestXML();
					mav.addObject("dataSource", datasource);
					
					step = "4";
				}else if(step.equals("4")){
					//remove temp to real collection;
					requestUrl = "/management/collections/operate.json";
					JSONObject result= httpPost(session, requestUrl)
						.addParameter("collectionId", collectionId)
						.addParameter("command", "promote").requestJSON();
					//TODO: 결과처리
					step = "5";
				}
			}else if(next.equals("back")){
				if(step.equals("2")){
					requestUrl = "/management/collections/collection-info-list.json";
					JSONObject serverListObject = httpPost(session, requestUrl).requestJSON();
					JSONArray serverList = serverListObject.optJSONArray("collectionInfoList");
					for(int inx=0;inx<serverList.length();inx++) {
						JSONObject serverInfo = serverList.optJSONObject(inx);
						if(collectionTmp.equals(serverInfo.optString("id"))) {
							mav.addObject("collectionName", serverInfo.optString("name"));
							mav.addObject("indexNode", serverInfo.optString("indexNode"));
							mav.addObject("searchNodeList", serverInfo.optString("searchNodeList"));
							mav.addObject("dataNodeList", serverInfo.optString("dataNodeList"));
						}
					}
					
					step = "1";
				}else if(step.equals("3")){
					step = "2";
				}else if(step.equals("4")){
					step = "3";
				}else if(step.equals("5")){
					step = "4";
				}
			}
			
			if(step.equals("1")){
				requestUrl = "/management/servers/list.json";
				JSONObject serverListObject = httpPost(session, requestUrl).requestJSON();
				mav.addObject("serverListObject",serverListObject);
			}else if(step.equals("2")){
			}else if(step.equals("3")){
				requestUrl = "/management/collections/schema.xml";
				Document document = httpPost(session, requestUrl).addParameter("collectionId", collectionTmp).addParameter("type", "workSchema")
						.requestXML();
				mav.addObject("schemaDocument",document);
				
				requestUrl = "/management/collections/data-type-list.json";
				PostMethod httpPost = httpPost(session, requestUrl);
				JSONObject typeList = httpPost.requestJSON();
				mav.addObject("typeList", typeList);
					
			}else if(step.equals("4")){
				requestUrl = "/management/collections/schema.xml";
				Document schema = httpPost(session, requestUrl)
					.addParameter("collectionId", collectionTmp)
					.addParameter("type", "workSchema").requestXML();
				mav.addObject("schemaDocument", schema);
			}else if(step.equals("5")){
			}
			
			mav.addObject("step", step);
			mav.addObject("next", next);
			mav.addObject("collectionId", collectionId);
			mav.addObject("collectionTmp", collectionTmp);
			mav.setViewName("manager/collections/createCollectionWizard");
		} catch (Exception e) {
			logger.error("",e);
		} finally {
		}
		return mav;
	}

}
