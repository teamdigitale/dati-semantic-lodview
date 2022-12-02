<%@page session="true" %>
<%@taglib uri="http://www.springframework.org/tags" prefix="sp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html version="XHTML+RDFa 1.1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
>
<head data-color="${colorPair}" profile="http://www.w3.org/1999/xhtml/vocab">
    <title>${results.getTitle()}&mdash;LodView</title>
    <jsp:include page="inc/header.jsp"></jsp:include>
</head>
<body id="top">
<article>
    <div id="logoBanner">
        <div id="logo">
            <!-- placeholder for logo -->
        </div>
    </div>
    <header>
        <hgroup>
            <h1>
                <span>${conf.getHomeTitle()}</span>
            </h1>
            <h2></h2>
        </hgroup>
        <div id="abstract">
            <div class="value">
           	 ${conf.getHomeDescription()}
            </div>
        </div>

    </header>

    <aside class="empty"></aside>

    <div id="directs">

        <div class="value">
       	 ${conf.getHomeContent()}
        </div>

    </div>

    <div id="inverses" class="empty"></div>
    <jsp:include page="inc/custom_footer.jsp"></jsp:include>
</article>
<jsp:include page="inc/footer.jsp"></jsp:include>

</body>
</html>
