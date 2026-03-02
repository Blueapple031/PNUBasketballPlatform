package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Comment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CommentRepository extends JpaRepository<Comment, Long> {

    @Query("SELECT c FROM Comment c JOIN FETCH c.user WHERE c.post.postId = :postId AND c.deletedAt IS NULL ORDER BY c.createdAt ASC")
    List<Comment> findByPostIdAndDeletedAtIsNull(@Param("postId") Long postId);

    @Query("SELECT c.post.postId, COUNT(c) FROM Comment c WHERE c.post.postId IN :postIds AND c.deletedAt IS NULL GROUP BY c.post.postId")
    List<Object[]> countByPostIds(@Param("postIds") List<Long> postIds);
}
