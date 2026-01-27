package com.lms.education.module.user.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import java.time.LocalDateTime;

@Entity
@Table(name = "activity_logs")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ActivityLog {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(length = 36)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @Column(name = "actor_name", length = 100, columnDefinition = "NVARCHAR(100)")
    private String actorName;

    @Column(length = 50)
    private String module;

    @Column(nullable = false, length = 50)
    private String action;

    @Column(name = "target_type", length = 50)
    private String targetType;

    @Column(name = "target_id", length = 36)
    private String targetId;

    @Column(columnDefinition = "TEXT")
    private String details;

    public enum LogStatus {
        success, failure, error
    }

    @Enumerated(EnumType.STRING)
    @Column(length = 20)
    @Builder.Default
    private LogStatus status = LogStatus.success;

    @Column(name = "ip_address", length = 45)
    private String ipAddress;

    @Column(name = "user_agent", columnDefinition = "TEXT")
    private String userAgent;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
