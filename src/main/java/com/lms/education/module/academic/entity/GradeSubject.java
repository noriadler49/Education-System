package com.lms.education.module.academic.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "grade_subjects",
        // Mapping unique constraint từ DB vào JPA
        uniqueConstraints = {
                @UniqueConstraint(name = "uq_grade_subject", columnNames = {"grade_id", "subject_id"})
        }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GradeSubject {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(length = 36)
    private String id;

    // --- Quan hệ với Grade (Khối) ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "grade_id", nullable = false)
    private Grade grade;

    // --- Quan hệ với Subject (Môn học) ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "subject_id", nullable = false)
    private Subject subject;

    public enum SubjectType {
        required, // Môn bắt buộc
        elective  // Môn tự chọn
    }

    @Enumerated(EnumType.STRING)
    @Column(name = "subject_type", length = 20, columnDefinition = "VARCHAR(20) DEFAULT 'required'")
    @Builder.Default
    private SubjectType subjectType = SubjectType.required;

    // Cờ bật/tắt LMS (Có cho phép học online môn này ở khối này không)
    @Column(name = "is_lms_enabled", columnDefinition = "BOOLEAN DEFAULT TRUE")
    @Builder.Default
    private Boolean isLmsEnabled = true;

    // Thứ tự hiển thị trên bảng điểm (VD: Toán=1, Văn=2...)
    @Column(name = "display_order", columnDefinition = "INT DEFAULT 0")
    @Builder.Default
    private Integer displayOrder = 0;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
