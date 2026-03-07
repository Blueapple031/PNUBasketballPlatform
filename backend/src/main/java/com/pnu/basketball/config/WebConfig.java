package com.pnu.basketball.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Bean
    public RestTemplate restTemplate() {
        return new RestTemplate();
    }

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // 루트 경로를 health-check.html로 리다이렉트
        registry.addViewController("/").setViewName("forward:/health-check.html");
        // /admin, /admin/ → admin/index.html
        registry.addViewController("/admin").setViewName("redirect:/admin/index.html");
        registry.addViewController("/admin/").setViewName("redirect:/admin/index.html");
    }

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        // /admin/** → classpath:/static/admin/ (기본 정적 리소스보다 우선)
        registry.addResourceHandler("/admin/**")
                .addResourceLocations("classpath:/static/admin/");
    }
}
