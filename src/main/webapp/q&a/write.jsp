<%@ page contentType="text/html; charset=utf-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layouts"%>

<layout:main>
<div class="pt-50"></div>
	<div class="writeContent">
		<div class="white">
		<div>
			<h1>Q&A</h1>
		</div>
		<div>
			<form method="post" action="<c:url value="/Q&A/write" />" target="ifrmProcess" autocomplete="off">
				<div class="write"><input class="displayNone" type="text" disabled="disabled" value="${member.id}">
				<input type="hidden" name="memId" value="${member.id}">
				<input class="subjectInput" type="text" name="subject" placeholder="제목 입력">
				<textarea class="textarea" rows="20" cols="150" name="question">내용 입력</textarea>
				</div>
				<div>
					<button class="writeBtn" type="reset">다시 작성</button>
					<button class="writeBtn" type="submit" onclick="return confirm('등록한 뒤 수정이 불가합니다. 정말 등록합니까?');">등록 하기</button>
				</div>
			</form>
		</div>
		</div>
	</div>
</layout:main>