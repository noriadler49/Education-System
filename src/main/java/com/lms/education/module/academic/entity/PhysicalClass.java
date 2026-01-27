package com.lms.education.module.academic.entity;

import com.lms.education.module.user.entity.Teacher;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(
        name = "physical_classes",
        uniqueConstraints = {
                // Ràng buộc duy nhất: Trong 1 năm học, tên lớp không được trùng nhau (VD: Chỉ có 1 lớp 10A1)
                @UniqueConstraint(name = "uq_class_name_year", columnNames = {"name", "school_year_id"})
        }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PhysicalClass {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(length = 36)
    private String id;

    @Column(nullable = false, length = 100)
    private String name; // Ví dụ: 10A1, 12A5

    // --- Quan hệ Năm học ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "school_year_id", nullable = false)
    private SchoolYear schoolYear;

    // --- Quan hệ Khối ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "grade_id", nullable = false)
    private Grade grade;

    // --- Quan hệ Giáo viên chủ nhiệm ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "homeroom_teacher_id")
    private Teacher homeroomTeacher;

    @Column(name = "max_students", nullable = false)
    private Integer maxStudents; // Sĩ số tối đa

    @Column(name = "room_number", length = 50)
    private String roomNumber; // Phòng học, VD: "B102"

    public enum ClassStatus {
        active,
        archived
    }

    @Enumerated(EnumType.STRING)
    @Column(length = 20, columnDefinition = "VARCHAR(20) DEFAULT 'active'")
    @Builder.Default
    private ClassStatus status = ClassStatus.active;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
