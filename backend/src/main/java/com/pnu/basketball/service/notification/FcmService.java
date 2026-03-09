package com.pnu.basketball.service.notification;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.messaging.*;
import com.pnu.basketball.domain.User;
import com.pnu.basketball.repository.UserRepository;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class FcmService {

    private final UserRepository userRepository;

    private FirebaseMessaging firebaseMessaging;

    @PostConstruct
    public void init() {
        try {
            if (FirebaseApp.getApps().isEmpty()) {
                ClassPathResource resource = new ClassPathResource("firebase-service-account.json");
                if (!resource.exists()) {
                    log.warn("firebase-service-account.json이 없습니다. FCM 푸시 발송이 비활성화됩니다. Firebase Console에서 서비스 계정 키를 다운로드하여 src/main/resources/에 배치하세요.");
                    return;
                }
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(resource.getInputStream()))
                        .build();
                FirebaseApp.initializeApp(options);
            }
            this.firebaseMessaging = FirebaseMessaging.getInstance();
            log.info("Firebase Admin SDK 초기화 완료");
        } catch (IOException e) {
            log.error("Firebase 초기화 실패: {}. FCM 푸시 발송이 비활성화됩니다.", e.getMessage());
        }
    }

    public void sendToUser(Long userId, String title, String body) {
        User user = userRepository.findById(userId).orElse(null);
        if (user == null || user.getFcmToken() == null) return;
        sendToToken(user.getFcmToken(), title, body);
    }

    public void sendToToken(String fcmToken, String title, String body) {
        sendToToken(fcmToken, title, body, null);
    }

    public void sendToToken(String fcmToken, String title, String body, Map<String, String> data) {
        if (firebaseMessaging == null) return;
        try {
            Message.Builder builder = Message.builder()
                    .setToken(fcmToken)
                    .setNotification(Notification.builder()
                            .setTitle(title)
                            .setBody(body)
                            .build())
                    .setAndroidConfig(AndroidConfig.builder()
                            .setPriority(AndroidConfig.Priority.HIGH)
                            .setNotification(AndroidNotification.builder()
                                    .setChannelId("high_importance_channel")
                                    .build())
                            .build())
                    .setApnsConfig(ApnsConfig.builder()
                            .setAps(Aps.builder().setSound("default").build())
                            .build());
            if (data != null && !data.isEmpty()) {
                data.forEach(builder::putData);
            }
            builder.putData("click_action", "FLUTTER_NOTIFICATION_CLICK");
            firebaseMessaging.sendAsync(builder.build());
        } catch (Exception e) {
            log.warn("FCM 발송 실패: {}", e.getMessage());
        }
    }

    public void sendToMultipleUsers(List<Long> userIds, String title, String body) {
        List<User> users = userRepository.findAllById(userIds);
        users.stream()
                .filter(u -> u.getFcmToken() != null)
                .forEach(u -> sendToToken(u.getFcmToken(), title, body));
    }
}
