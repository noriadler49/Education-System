CREATE DATABASE lms_db;
USE lms_db;

-- ============================================
-- 1. NHÓM BẢNG CẤU HÌNH HỆ THỐNG
-- ============================================

-- 1.1. Bảng school_years (Năm học)
CREATE TABLE school_years (
                              id VARCHAR(36) PRIMARY KEY,
                              name NVARCHAR(50) NOT NULL,
                              start_date DATE NOT NULL,
                              end_date DATE NOT NULL,
                              status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'archived')),
                              created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                              updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE subjects (
                          id VARCHAR(36) PRIMARY KEY,
                          name NVARCHAR(100) NOT NULL,
                          description TEXT DEFAULT NULL,
                          is_active BOOLEAN DEFAULT TRUE,
                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE grades (
                        id VARCHAR(36) PRIMARY KEY,
                        name NVARCHAR(20) NOT NULL,
                        level INT NOT NULL,
                        is_active BOOLEAN DEFAULT TRUE,
                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- 1.4. Bảng grade_subjects (Cấu hình Môn học theo Khối)
CREATE TABLE grade_subjects (
                                id VARCHAR(36) PRIMARY KEY,
                                grade_id VARCHAR(36) NOT NULL,
                                subject_id VARCHAR(36) NOT NULL,
                                subject_type VARCHAR(20) DEFAULT 'required' CHECK (subject_type IN ('required', 'elective')),
                                is_lms_enabled BOOLEAN DEFAULT TRUE,
                                display_order INT DEFAULT 0,         -- Để sắp xếp trên bảng điểm/menu (Toán -> Văn -> Anh...)
                                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                CONSTRAINT uq_grade_subject UNIQUE (grade_id, subject_id),
                                CONSTRAINT fk_grade_subjects_grade FOREIGN KEY (grade_id) REFERENCES grades(id) ON DELETE CASCADE,
                                CONSTRAINT fk_grade_subjects_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE
);

-- ============================================
-- 2. NHÓM BẢNG QUẢN LÝ NGƯỜI DÙNG
-- ============================================

-- 2.1. Bảng departments (Khoa/Bộ môn)
CREATE TABLE departments (
                             id VARCHAR(36) PRIMARY KEY,
                             name NVARCHAR(100) NOT NULL,
                             description TEXT DEFAULT NULL,
                             type VARCHAR(20) DEFAULT 'academic' CHECK (type IN ('academic', 'office')),  -- Phân loại: 'academic' (Tổ chuyên môn - Có đi dạy). 'office' (Phòng ban hành chính - Kế toán, Y tế...)
                             is_active BOOLEAN DEFAULT TRUE,
                             created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                             updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);


CREATE TABLE roles (
                       id VARCHAR(36) PRIMARY KEY,
                       code VARCHAR(50) UNIQUE NOT NULL,
                       name NVARCHAR(100) NOT NULL,
                       status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
                       created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                       updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

create table permissions
(
    id int auto_increment primary key,
    code varchar(120) not null,
    scope enum ('company', 'workspace', 'project') not null,
    name nvarchar(120) default null,
    description text default null
);

create table role_permission
(
    role_id VARCHAR(36) not null,
    permission_id int not null,
    primary key (role_id, permission_id),
    constraint role_permission_ibfk_1 foreign key (role_id) references roles (id) ON DELETE CASCADE,
    constraint role_permission_ibfk_2 foreign key (permission_id) references permissions (id) ON DELETE CASCADE
);

CREATE TABLE users (
                       id VARCHAR(36) PRIMARY KEY,
                       role_id VARCHAR(36) NOT NULL,
                       email VARCHAR(100) UNIQUE NOT NULL,
                       password VARCHAR(255) NOT NULL,
                       status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
                       created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                       updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       last_login DATETIME,
                       CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- 2.4. Bảng students (Thông tin Học sinh)
CREATE TABLE students (
                          id VARCHAR(36) PRIMARY KEY,
                          user_id VARCHAR(36) UNIQUE DEFAULT NULL,
                          student_code VARCHAR(20) NOT NULL UNIQUE,
                          full_name VARCHAR(100) NOT NULL,
                          date_of_birth DATE NOT NULL,
                          gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
                          current_class_id VARCHAR(36) DEFAULT NULL,
                          address TEXT NOT NULL,
                          parent_phone VARCHAR(20) NOT NULL,
                          parent_name NVARCHAR(100) NOT NULL,
                          admission_year INT,  -- Khóa nhập học (Niên khóa)
                          status VARCHAR(20) DEFAULT 'studying'
                              CHECK (status IN ('studying', 'graduated', 'transferred', 'dropped_out', 'reserved')),
                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          CONSTRAINT fk_students_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 2.5. Bảng teachers (Thông tin Giáo viên)
CREATE TABLE teachers (
                          id VARCHAR(36) PRIMARY KEY,
                          user_id VARCHAR(36) UNIQUE DEFAULT NULL,
                          teacher_code VARCHAR(20) NOT NULL UNIQUE,
                          full_name VARCHAR(100) NOT NULL,
                          date_of_birth DATE,
                          gender VARCHAR(10) CHECK (gender IN ('male', 'female', 'other')),
                          phone VARCHAR(20),
                          email_contact VARCHAR(100),
                          address TEXT NOT NULL,
                          department_id VARCHAR(36),
                          position VARCHAR(50) NOT NULL, -- Chức vụ (Tổ trưởng, Hiệu phó...)
                          degree VARCHAR(50) NOT NULL,   -- Học vị (Cử nhân, Thạc sĩ, Tiến sĩ)
                          major VARCHAR(100) DEFAULT NULL,   -- Chuyên môn (Sư phạm Toán, CNTT...)
                          start_date DATE,
                          status VARCHAR(20) DEFAULT 'working'
                              CHECK (status IN ('working', 'on_leave', 'retired', 'quit')),
                          created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                          updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                          CONSTRAINT fk_teachers_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                          CONSTRAINT fk_teachers_department FOREIGN KEY (department_id) REFERENCES departments(id) ON DELETE SET NULL
);

-- ============================================
-- 3. NHÓM BẢNG LỚP HỌC VẬT LÝ
-- ============================================

CREATE TABLE physical_classes (
                                  id VARCHAR(36) PRIMARY KEY,
                                  name VARCHAR(100) NOT NULL,
                                  school_year_id VARCHAR(36) NOT NULL,
                                  grade_id VARCHAR(36) NOT NULL,
                                  homeroom_teacher_id VARCHAR(36) DEFAULT NULL,
                                  max_students INT NOT NULL,
                                  room_number VARCHAR(50) DEFAULT NULL,
                                  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'archived')),
                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                  CONSTRAINT fk_physical_classes_school_year FOREIGN KEY (school_year_id) REFERENCES school_years(id) ON DELETE CASCADE,
                                  CONSTRAINT fk_physical_classes_grade FOREIGN KEY (grade_id) REFERENCES grades(id) ON DELETE CASCADE,
                                  CONSTRAINT fk_physical_classes_homeroom_teacher FOREIGN KEY (homeroom_teacher_id) REFERENCES teachers(id) ON DELETE SET NULL,
                                  CONSTRAINT uq_class_name_year UNIQUE (name, school_year_id)
);

-- Add FK cho students sau khi đã có bảng classes
ALTER TABLE students ADD CONSTRAINT fk_students_current_class FOREIGN KEY (current_class_id) REFERENCES physical_classes(id) ON DELETE SET NULL;

CREATE TABLE class_students (
                                id VARCHAR(36) PRIMARY KEY,
                                physical_class_id VARCHAR(36) NOT NULL,
                                student_id VARCHAR(36) NOT NULL,
                                student_number INT,
                                enrollment_date DATE DEFAULT (CURRENT_DATE), -- Ngày bắt đầu học tại lớp này
                                end_date DATE, -- Chỉ có giá trị khi status là 'transferred' hoặc 'dropped'
                                status VARCHAR(20) DEFAULT 'studying' CHECK (status IN ('studying', 'transferred', 'dropped', 'completed')),
                                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                CONSTRAINT uq_class_student UNIQUE (physical_class_id, student_id), -- Ràng buộc: Một học sinh không thể xuất hiện 2 lần trong cùng 1 lớp
                                CONSTRAINT fk_class_students_class FOREIGN KEY (physical_class_id) REFERENCES physical_classes(id) ON DELETE CASCADE,
                                CONSTRAINT fk_class_students_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

CREATE TABLE class_transfer_history (
                                        id VARCHAR(36) PRIMARY KEY,
                                        student_id VARCHAR(36) NOT NULL,
                                        from_class_id VARCHAR(36) NOT NULL,
                                        to_class_id VARCHAR(36) NOT NULL,
                                        transfer_date DATE NOT NULL,
                                        reason TEXT DEFAULT NULL,
                                        created_by VARCHAR(36),
                                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                        CONSTRAINT fk_transfer_history_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
                                        CONSTRAINT fk_transfer_history_from_class FOREIGN KEY (from_class_id) REFERENCES physical_classes(id) ON DELETE CASCADE,
                                        CONSTRAINT fk_transfer_history_to_class FOREIGN KEY (to_class_id) REFERENCES physical_classes(id) ON DELETE CASCADE,
                                        CONSTRAINT fk_transfer_history_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
                                        CONSTRAINT chk_diff_class CHECK (from_class_id <> to_class_id) -- Không cho phép chuyển sang chính lớp cũ
);

-- ============================================
-- 4. NHÓM BẢNG PHÂN CÔNG & LỚP TRỰC TUYẾN
-- ============================================

CREATE TABLE teaching_assignments (
                                      id VARCHAR(36) PRIMARY KEY,
                                      physical_class_id VARCHAR(36) NOT NULL,
                                      subject_id VARCHAR(36) NOT NULL,
                                      teacher_id VARCHAR(36) NOT NULL,
                                      school_year_id VARCHAR(36) NOT NULL,
                                      semester_id VARCHAR(36) NOT NULL,    --  Bổ sung Học kỳ để phân công chi tiết hơn
                                      online_class_id VARCHAR(36),
                                      status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
                                      assigned_date DATE DEFAULT (CURRENT_DATE),
                                      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                      CONSTRAINT fk_teaching_assignments_class FOREIGN KEY (physical_class_id) REFERENCES physical_classes(id) ON DELETE CASCADE,
                                      CONSTRAINT fk_teaching_assignments_subject FOREIGN KEY (subject_id) REFERENCES subjects(id) ON DELETE CASCADE,
                                      CONSTRAINT fk_teaching_assignments_teacher FOREIGN KEY (teacher_id) REFERENCES teachers(id) ON DELETE CASCADE,
                                      CONSTRAINT fk_teaching_assignments_school_year FOREIGN KEY (school_year_id) REFERENCES school_years(id) ON DELETE CASCADE,
                                      CONSTRAINT uq_teaching_assignment UNIQUE (physical_class_id, subject_id, semester_id) -- Trong cùng 1 Lớp, 1 Môn, 1 Học kỳ -> Chỉ có 1 Giáo viên chính thức
);

CREATE TABLE online_classes (
                                id VARCHAR(36) PRIMARY KEY,
                                name NVARCHAR(150) NOT NULL, -- VD: Toán 10A1 - HK1
                                teaching_assignment_id VARCHAR(36) NOT NULL UNIQUE,
                                status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'archived')),
                                created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                CONSTRAINT fk_online_classes_assignment FOREIGN KEY (teaching_assignment_id) REFERENCES teaching_assignments(id) ON DELETE CASCADE
);

CREATE TABLE online_class_students (
                                       id VARCHAR(36) PRIMARY KEY,
                                       online_class_id VARCHAR(36) NOT NULL,
                                       student_id VARCHAR(36) NOT NULL,
    -- 'system': Tự động từ lớp vật lý sang (Không được xóa tay)
    -- 'manual': Giáo viên add thêm vào (Được phép xóa)
                                       enrollment_source VARCHAR(20) DEFAULT 'system' CHECK (enrollment_source IN ('system', 'manual')),
                                       enrolled_date DATE DEFAULT (CURRENT_DATE),
                                       status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'removed', 'completed')),
                                       created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                       updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                       CONSTRAINT uq_online_class_student UNIQUE (online_class_id, student_id),
                                       CONSTRAINT fk_online_class_students_class FOREIGN KEY (online_class_id) REFERENCES online_classes(id) ON DELETE CASCADE,
                                       CONSTRAINT fk_online_class_students_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
);

-- ============================================
-- 5. NHÓM BẢNG TÀI LIỆU HỌC TẬP
-- ============================================

CREATE TABLE learning_materials (
                                    id VARCHAR(36) PRIMARY KEY,
                                    online_class_id VARCHAR(36) NOT NULL,
                                    title VARCHAR(255) NOT NULL,
                                    description TEXT,
                                    file_type VARCHAR(20) CHECK (file_type IN ('slide', 'video', 'document', 'link', 'other')),
                                    file_path VARCHAR(500),
                                    file_size BIGINT,
                                    file_name VARCHAR(255),
                                    status VARCHAR(20) DEFAULT 'unpublished' CHECK (status IN ('published', 'unpublished')),
                                    uploaded_by VARCHAR(36),
                                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                    CONSTRAINT fk_learning_materials_class FOREIGN KEY (online_class_id) REFERENCES online_classes(id) ON DELETE CASCADE,
                                    CONSTRAINT fk_learning_materials_uploaded_by FOREIGN KEY (uploaded_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================
-- 6. NHÓM BẢNG BÀI TẬP
-- ============================================

CREATE TABLE assignments (
                             id VARCHAR(36) PRIMARY KEY,
                             online_class_id VARCHAR(36) NOT NULL,
                             title NVARCHAR(255) NOT NULL,
                             description TEXT,
                             attachment_path VARCHAR(500) DEFAULT NULL, -- File đính kèm đề bài (Word/PDF) cho bài Tự luận
                             assignment_type VARCHAR(30) CHECK (assignment_type IN ('multiple_choice', 'essay', 'file_upload', 'mixed')),
                             start_time DATETIME, -- Thời gian mở đề
                             due_time DATETIME,   -- Hạn chót nộp bài
                             duration_minutes INT, -- Thời gian làm bài (VD: 45 phút)
                             max_score DECIMAL(5,2) DEFAULT 10.00,
                             allow_late_submission BOOLEAN DEFAULT FALSE, -- Cho phép nộp muộn?
                             max_attempts INT DEFAULT 1, -- Số lần làm bài tối đa (0 = không giới hạn)
                             shuffle_questions BOOLEAN DEFAULT FALSE, -- Tráo câu hỏi?
                             view_answers BOOLEAN DEFAULT FALSE, -- Xem đáp án ngay sau khi nộp?
                             status VARCHAR(20) DEFAULT 'unpublished' CHECK (status IN ('published', 'unpublished', 'draft')),
                             created_by VARCHAR(36),
                             created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                             updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             CONSTRAINT fk_assignments_class FOREIGN KEY (online_class_id) REFERENCES online_classes(id) ON DELETE CASCADE,
                             CONSTRAINT fk_assignments_created_by FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE assignment_questions (
                                      id VARCHAR(36) PRIMARY KEY,
                                      assignment_id VARCHAR(36) NOT NULL,
                                      question_order INT NOT NULL, -- Thứ tự câu 1, 2, 3
                                      question_text TEXT NOT NULL, -- Nội dung câu hỏi
                                      explanation TEXT,-- Lời giải chi tiết (Học sinh chỉ thấy sau khi nộp bài)
                                      question_type VARCHAR(30) CHECK (question_type IN ('multiple_choice', 'essay', 'file_upload')),
                                      score DECIMAL(5,2), -- Điểm số của câu này (Ví dụ: 0.25 điểm)
                                      created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                      updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                      CONSTRAINT fk_assignment_questions_assignment FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE
);

CREATE TABLE question_options (
                                  id VARCHAR(36) PRIMARY KEY,
                                  question_id VARCHAR(36) NOT NULL,
                                  display_order INT NOT NULL,
                                  option_text TEXT,
                                  is_correct BOOLEAN DEFAULT FALSE,
                                  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                  CONSTRAINT fk_question_options_question FOREIGN KEY (question_id) REFERENCES assignment_questions(id) ON DELETE CASCADE
);

-- 6.4.Bảng assignment_submissions (Gộp cả thông tin chấm điểm)
CREATE TABLE assignment_submissions (
                                        id VARCHAR(36) PRIMARY KEY,
                                        assignment_id VARCHAR(36) NOT NULL,
                                        student_id VARCHAR(36) NOT NULL,
                                        student_note TEXT, -- Ghi chú của học sinh
                                        submission_status VARCHAR(20) DEFAULT 'not_submitted'
                                            CHECK (submission_status IN ('not_submitted', 'draft', 'submitted', 'graded', 'late')),
                                        submitted_at DATETIME,
                                        is_late BOOLEAN DEFAULT FALSE,
                                        attempt_count INT DEFAULT 1,
                                        score DECIMAL(5,2),        -- Điểm số
                                        teacher_feedback TEXT,     -- Lời phê
                                        graded_by VARCHAR(36),     -- Giáo viên chấm (Hoặc NULL nếu máy chấm)
                                        graded_at DATETIME,        -- Thời điểm chấm
    -- Cờ này quan trọng: Để biết bài này là máy chấm xong hay giáo viên chấm
                                        grading_method VARCHAR(20) DEFAULT 'manual' CHECK (grading_method IN ('auto', 'manual')),
                                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                        CONSTRAINT uq_assignment_student UNIQUE (assignment_id, student_id),
                                        CONSTRAINT fk_submissions_assignment FOREIGN KEY (assignment_id) REFERENCES assignments(id) ON DELETE CASCADE,
                                        CONSTRAINT fk_submissions_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
                                        CONSTRAINT fk_submissions_grader FOREIGN KEY (graded_by) REFERENCES users(id) ON DELETE SET NULL
);

-- 6.5. Bảng submission_attachments (File đính kèm trong bài làm)
CREATE TABLE submission_attachments (
                                        id VARCHAR(36) PRIMARY KEY,
                                        submission_id VARCHAR(36) NOT NULL,
                                        file_name VARCHAR(255) NOT NULL, -- Tên file gốc (Ví dụ: Bai_tap_Toan_Trang1.jpg)
                                        file_path VARCHAR(500) NOT NULL, -- Đường dẫn file trên Server/Cloud (Ví dụ: /uploads/homework/xyz.jpg)
    -- Loại file (Để hiển thị icon Word, Excel, PDF, Ảnh...)
                                        file_type VARCHAR(50) CHECK (file_type IN ('image', 'document', 'video', 'audio', 'compressed', 'other')),
                                        file_size BIGINT, -- Dung lượng file (Lưu bằng bytes - Để thống kê dung lượng lưu trữ)
                                        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                        CONSTRAINT fk_attachments_submission FOREIGN KEY (submission_id) REFERENCES assignment_submissions(id) ON DELETE CASCADE
);

CREATE TABLE submission_answers (
                                    id VARCHAR(36) PRIMARY KEY,
                                    submission_id VARCHAR(36) NOT NULL,
                                    question_id VARCHAR(36) NOT NULL,
                                    answer_text TEXT,      -- Cho câu tự luận/điền từ
                                    selected_option_id VARCHAR(36), -- Cho câu trắc nghiệm
                                    is_correct BOOLEAN,
                                    score DECIMAL(5,2) DEFAULT 0, -- Điểm đạt được của riêng câu này
                                    feedback TEXT,
                                    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                                    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                    CONSTRAINT fk_submission_answers_submission FOREIGN KEY (submission_id) REFERENCES assignment_submissions(id) ON DELETE CASCADE,
                                    CONSTRAINT fk_submission_answers_question FOREIGN KEY (question_id) REFERENCES assignment_questions(id) ON DELETE CASCADE,
                                    CONSTRAINT fk_submission_answers_option FOREIGN KEY (selected_option_id) REFERENCES question_options(id) ON DELETE SET NULL
);

-- ============================================
-- 7. NHÓM BẢNG THÔNG BÁO
-- ============================================

CREATE TABLE announcements (
                               id VARCHAR(36) PRIMARY KEY,
                               title VARCHAR(255) NOT NULL,
                               content TEXT,
                               scope VARCHAR(20) NOT NULL CHECK (scope IN ('physical_class', 'online_class')),
                               physical_class_id VARCHAR(36),
                               online_class_id VARCHAR(36),
                               attachment_path VARCHAR(500), -- File đính kèm (Ví dụ: File PDF lịch thi, Ảnh banner sự kiện)
                               created_by VARCHAR(36), -- Người đăng
                               published_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                               updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                               CONSTRAINT fk_announcements_physical FOREIGN KEY (physical_class_id) REFERENCES physical_classes(id) ON DELETE CASCADE,
                               CONSTRAINT fk_announcements_online FOREIGN KEY (online_class_id) REFERENCES online_classes(id) ON DELETE CASCADE,
                               CONSTRAINT fk_announcements_creator FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================
-- 8. BẢNG BỔ TRỢ
-- ============================================

CREATE TABLE activity_logs (
                               id VARCHAR(36) PRIMARY KEY,
                               user_id VARCHAR(36),
                               actor_name NVARCHAR(100),
                               module VARCHAR(50), -- Phân hệ (Để lọc nhanh: Chỉ xem log điểm, Log đăng nhập...)
                               action VARCHAR(50) NOT NULL, -- Hành động cụ thể (VD: 'LOGIN', 'UPDATE_SCORE', 'DELETE_CLASS')
                               target_type VARCHAR(50), -- VD: 'assignment_submissions'
                               target_id VARCHAR(36),   -- ID của dòng bị sửa
                               details JSON, -- Chứa: dữ liệu cũ, dữ liệu mới, lý do...
    -- Trạng thái hành động (Quan trọng để phát hiện hack/lỗi)
                               status VARCHAR(20) DEFAULT 'success' CHECK (status IN ('success', 'failure', 'error')),
                               ip_address VARCHAR(45),
                               user_agent TEXT, -- Lưu tên trình duyệt/thiết bị
                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                               CONSTRAINT fk_activity_logs_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE TABLE notifications (
                               id VARCHAR(36) PRIMARY KEY,
                               user_id VARCHAR(36) NOT NULL, -- Người nhận thông báo
                               sender_id VARCHAR(36),
                               title NVARCHAR(255) NOT NULL,
                               message TEXT,
                               type VARCHAR(30) CHECK (type IN ('assignment', 'grade', 'announcement', 'system', 'comment')),
    -- related_type: 'assignments', 'submissions', 'announcements'
    -- related_id: UUID của đối tượng tương ứng
                               related_type VARCHAR(50),
                               related_id VARCHAR(36),
                               metadata JSON,
                               read_at DATETIME,
                               created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
                               CONSTRAINT fk_notifications_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                               CONSTRAINT fk_notifications_sender FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ============================================
-- TẠO INDEX ĐỂ TỐI ƯU HIỆU SUẤT
-- ============================================

CREATE INDEX idx_physical_classes_school_year ON physical_classes(school_year_id);
CREATE INDEX idx_physical_classes_grade ON physical_classes(grade_id);
CREATE INDEX idx_online_classes_assignment ON online_classes(teaching_assignment_id);
CREATE INDEX idx_teaching_assignments_teacher ON teaching_assignments(teacher_id);
CREATE INDEX idx_teaching_assignments_class ON teaching_assignments(physical_class_id);
CREATE INDEX idx_teaching_assignments_subject ON teaching_assignments(subject_id);
CREATE INDEX idx_assignments_class ON assignments(online_class_id);
CREATE INDEX idx_assignments_status ON assignments(status);
CREATE INDEX idx_submissions_student ON assignment_submissions(student_id);
CREATE INDEX idx_submissions_assignment ON assignment_submissions(assignment_id);
CREATE INDEX idx_submissions_status ON assignment_submissions(submission_status);
CREATE INDEX idx_class_students_class ON class_students(physical_class_id);
CREATE INDEX idx_class_students_student ON class_students(student_id);
CREATE INDEX idx_announcements_class ON announcements(physical_class_id);
CREATE INDEX idx_announcements_published ON announcements(published_at);
CREATE INDEX idx_users_role ON users(role_id);
CREATE INDEX idx_notifications_user_read ON notifications(user_id, read_at);
CREATE INDEX idx_activity_logs_user ON activity_logs(user_id);
CREATE INDEX idx_activity_logs_module ON activity_logs(module);

SELECT 'Database LMS đã được tạo thành công!' AS message;