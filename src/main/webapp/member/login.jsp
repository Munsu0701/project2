<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layouts"%>

<layout:main title="로그인">
	<div class="content">
		<form target="ifrmProcess" action="<c:url value="/login" />"
			method="post">

			<div class="login">
						<div class="text">아이디</div>
						<input class="width100" type="text" name="id"> <br>
						<div class="text">비밀번호</div>
						<input class="width100" type="password" name="pw"> <br>
				
						<button class="loginBtn">로그인</button>
				</div>
		</form>
	</div>
</layout:main>