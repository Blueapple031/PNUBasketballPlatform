package com.pnu.basketball.repository;

import com.pnu.basketball.domain.Comment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.UUID;

@Repository
public interface CommentRepository extends JpaRepository<Comment, UUID> {

    List<Comment> findByPost_IdOrderByCreatedAtAsc(UUID postId);

    long countByPost_Id(UUID postId);
}
