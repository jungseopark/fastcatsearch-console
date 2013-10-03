package org.fastcatsearch.console.web.controller.manager;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
@RequestMapping("/manager/dictionary")
public class DictionaryController {
	
	@RequestMapping("/{analysisId}/index")
	public ModelAndView index(@PathVariable String analysisId) {
		ModelAndView mav = new ModelAndView();
		mav.setViewName("manager/dictionary/index");
		mav.addObject("analysisId", analysisId);
		return mav;
	}
}
