package com.lms.education.module.academic.entity;

import com.lms.education.module.user.entity.Student;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(
        name = "class_students",
        uniqueConstraints = {
                // Ràng buộc duy nhất: Một học sinh không được ở trong cùng 1 lớp 2 lần
                @UniqueConstraint(name = "uq_class_student", columnNames = {"physical_class_id", "student_id"})
        }
)
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClassStudent {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(length = 36)
    private String id;

    // --- Quan hệ với Lớp học ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "physical_class_id", nullable = false)
    private PhysicalClass physicalClass;

    // --- Quan hệ với Học sinh ---
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "student_id", nullable = false)
    private Student student;

    // Số thứ tự trong sổ điểm (STT)
    @Column(name = "student_number")
    private Integer studentNumber;

    // Ngày vào lớp
    // @Builder.Default: Khi tạo mới bằng Java, mặc định lấy ngày hiện tại
    @Column(name = "enrollment_date", nullable = false)
    @Builder.Default
    private LocalDate enrollmentDate = LocalDate.now();

    // Ngày kết thúc (chuyển lớp, thôi học...)
    @Column(name = "end_date")
    private LocalDate endDate;

    public enum StudentStatus {
        studying,    // Đang học
        transferred, // Đã chuyển lớp/trường
        dropped,     // Bỏ học
        completed    // Hoàn thành (Tốt nghiệp/Lên lớp xong)
    }

    @Enumerated(EnumType.STRING)
    @Column(length = 20, columnDefinition = "VARCHAR(20) DEFAULT 'studying'")
    @Builder.Default
    private StudentStatus status = StudentStatus.studying;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
