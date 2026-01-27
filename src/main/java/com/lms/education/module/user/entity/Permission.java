package com.lms.education.module.user.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "permissions")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Permission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Column(nullable = false, length = 120)
    private String code;

    public enum PermissionScope {
        company,
        workspace,
        project
    }

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, columnDefinition = "ENUM('company', 'workspace', 'project')")
    private PermissionScope scope;

    @Column(length = 120, columnDefinition = "NVARCHAR(120)")
    private String name;

    @Column(columnDefinition = "TEXT")
    private String description;
}
