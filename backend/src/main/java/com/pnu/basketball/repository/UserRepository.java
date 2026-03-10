package com.pnu.basketball.repository;

import com.pnu.basketball.domain.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {

    @Query("SELECT u.userId FROM User u WHERE u.fcmToken IS NOT NULL")
    List<Long> findUserIdsWithFcmToken();
    Optional<User> findByEmail(String email);
    Optional<User> findByGoogleId(String googleId);
    Optional<User> findByKakaoId(String kakaoId);
    boolean existsByEmail(String email);
    boolean existsByRealName(String realName);
    boolean existsByGoogleId(String googleId);
    boolean existsByKakaoId(String kakaoId);
    boolean existsByStudentId(String studentId);
    boolean existsByStudentIdAndUserIdNot(String studentId, Long userId);

    @Query("SELECT u FROM User u " +
            "WHERE (:isPnuStudent IS NULL OR u.isPnuStudent = :isPnuStudent) " +
            "AND (:search IS NULL OR :search = '' OR LOWER(u.email) LIKE LOWER(CONCAT(CONCAT('%', :search), '%')) " +
            "OR LOWER(u.realName) LIKE LOWER(CONCAT(CONCAT('%', :search), '%')) " +
            "OR (u.studentId IS NOT NULL AND LOWER(u.studentId) LIKE LOWER(CONCAT(CONCAT('%', :search), '%'))))")
    Page<User> findAllForAdmin(@Param("isPnuStudent") Boolean isPnuStudent,
                               @Param("search") String search,
                               Pageable pageable);
}

