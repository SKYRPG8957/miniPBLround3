const SCRIPT_URL = "https://script.google.com/macros/s/AKfycbwV_2L5nEDzJ2egFB82LLSMhRhYqA8DtGakwiu_V-A16NtSwxD9fl3w8-rtVzK-1t0s0w/exec";
        // 수정 X!!!
        const form = document.getElementById('applicationForm');
        const submitBtn = document.getElementById('submitBtn');
        const messageDiv = document.getElementById('message');
        
        function showMessage(text, type) {
            messageDiv.textContent = text;
            messageDiv.className = `message ${type} show`;
            setTimeout(() => {
                messageDiv.classList.remove('show');
            }, 5000);
        }
        
        form.addEventListener('submit', async (e) => {
            e.preventDefault();
            
            
            
            submitBtn.disabled = true;
            submitBtn.textContent = 'Submitting...';
            // html 파일에서 <label> 태그 안에 있는 Id 일치 하는지 확인!
           const formData = {
                applicant: document.getElementById('applicant').value,
                team: document.getElementById('team').value,
                role: document.getElementById('role').value,
                email: document.getElementById('email').value,
                phoneNumber: document.getElementById('phoneNumber').value,
                reason: document.getElementById('reason').value
            };
            
            try {
                const response = await fetch(SCRIPT_URL, {
                    method: 'POST',
                    mode: 'no-cors',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify(formData)
                });
                
                showMessage('데이터 업로드 성공.', 'success');
                form.reset();
                
            } catch (error) {
                showMessage('데이터 업로드 실패.', 'error');
                console.error('Error:', error);
            } finally {
                submitBtn.disabled = false;
                submitBtn.textContent = 'Submit Application';
            }
        });