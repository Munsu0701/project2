<%-- <%@ tag description="메인 공통 레이아웃" pageEncoding="utf-8" %>
<%@ tag body-content="scriptless" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="layout" tagdir="/WEB-INF/tags/layouts" %>
<%@ attribute name="title" type="java.lang.String" %>

<layout:common title="${title}">
	<jsp:attribute name="header">
		<header>
			<section class="join-menu" >
				<div class="logo ml">
					<i class="xi-bars"></i>
					<a href="<c:url value="/" /> ">로고 부분</a>
				</div>
				<div class="layout_width">
					<c:if test="${empty member}" >
						<a href="<c:url value="/join" /> " >회원가입</a>
						<a href="<c:url value="/login" /> " class="mr">로그인</a>
					</c:if>
					<c:if test="${!empty member }">
						${member.fakeName}님 환영합니다. 
						<a href="<c:url value="/mypage" /> ">MyPage</a>
						<a href="<c:url value="/withdrawal" />" onclick="return confirm('탈퇴페이지로 이동하시겠습니까?');">회원탈퇴</a>
						<a href="<c:url value="/logout" /> ">로그아웃</a>
						<c:if test="${member.userType eq 'admin'}">
							<a href="<c:url value="/admin" /> " target="_blank"  >관리자 페이지</a>
						</c:if>
						<c:if test="${member.userType eq 'seller' or member.userType eq 'admin'}">
							<a href="<c:url value="/seller" /> " target="_blank"  >판매자 페이지</a>
						</c:if>
					</c:if>
				</div>
			</section>
		</header>
	</jsp:attribute>
	
	
	<jsp:attribute name="contents">
		<div class="bg_image">
			<div class="main_text">
				<h1>당신의 일상이 되는 책</h1>
				<h3>어디서든 당신과 함께</h3>
			</div>
		</div>

		
		<div class="book_text">
			<h1>당신을 기다리는 </h1>
			<h1>수많은 도서</h1>
			<h3>첫 달 무료 구독을 통해</h3>
			<h3>어떤 도서가 있는지 확인해보세요!</h3>
		</div>
		
	</jsp:attribute>
	
	<jsp:attribute name="menu">
		<c:if test="${!empty member}">
			<nav>
				<div class="layout_width">
					<a href="#">운동 기록</a>
					<a href="<c:url value="/purpose" /> ">추천 운동</a>
					<a href="<c:url value="/community" /> ">커뮤니티</a>
					<a href="#">Sport Shop</a>
				</div>
			</nav>
		</c:if>
	</jsp:attribute>
	<jsp:attribute name="footer">
		<footer>
			<div class="footer">
				 &copy; footer...
			</div>
		</footer>
	</jsp:attribute>
	
	<jsp:body>
		<main>
			<jsp:doBody />
		</main>
	</jsp:body>
	
</layout:common> --%>
