<%@page session="true" %>
<%@taglib uri="http://www.springframework.org/tags" prefix="sp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head data-color="${colorPair}">
    <title>${results.getTitle()}&mdash;LodView</title>
    <jsp:include page="inc/header.jsp"></jsp:include>
</head>
<body id="top">
<article>
    <jsp:include page="inc/schema_header.jsp"></jsp:include>
    <hgroup>
        <h1>
            <span>${conf.getHomeTitle()}</span>
        </h1>
        <div id="abstract">
            <div class="row mx-0">
                <div class="col-8">
                    <div class="value">
                        <h2 class="h2-24">${conf.getHomeDescription()}</h2>
                    </div>
                </div>
            </div>
        </div>
    </hgroup>

    <aside class="empty"></aside>

    <div id="directs">

        <div class="value">
            <h2 class="h2-24 col-8">${conf.getHomeContent()}</h2>
        </div>

    </div>

    <div id="inverses" class="empty"></div>
    <jsp:include page="inc/custom_footer.jsp"></jsp:include>
</article>
<jsp:include page="inc/footer.jsp"></jsp:include>
<jsp:include page="inc/schema_footer.jsp"></jsp:include>


</body>
</html>
