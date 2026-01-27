package com.lms.education.module.academic.entity;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "grades")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Grade {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @Column(length = 36)
    private String id;

    @Column(nullable = false, length = 20, columnDefinition = "NVARCHAR(20)")
    private String name;

    @Column(nullable = false)
    private Integer level; // Ví dụ: 10, 11, 12

    @Column(name = "is_active")
    @Builder.Default
    private Boolean isActive = true;

    @CreationTimestamp
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    // --- Quan hệ gợi ý (Optional) ---
    // Một Khối lớp sẽ có nhiều Lớp học (Classes)
    // Ví dụ: Khối 10 có 10A1, 10A2...
    /*
    @OneToMany(mappedBy = "grade", fetch = FetchType.LAZY)
    private List<PhysicalClass> classes; // Giả sử entity lớp học tên là PhysicalClass
    */
}
