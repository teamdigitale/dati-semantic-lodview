<%@page session="true" %>
<%@taglib uri="http://www.springframework.org/tags" prefix="sp" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html version="XHTML+RDFa 1.1">
<head data-color="${colorPair}" profile="http://www.w3.org/1999/xhtml/vocab">
    <title>LodView &mdash; error ${statusCode}</title>
    <jsp:include page="inc/header.jsp"></jsp:include>
</head>
<body id="errorPage" class="error${statusCode}">
<article>
    <jsp:include page="inc/schema_header.jsp"></jsp:include>
    <hgroup>
        <div id="owl"></div>
        <h1>${statusCode}</h1>
        <h2></h2>
    </hgroup>
    <div id="abstract"></div>
    <div id="bnodes">
        <c:choose>
            <c:when test="${statusCode =='500'}">
                <p>
                    <sp:message code='error.somethingWrong' text='something went wrong'/> <br>
                    <strong>${endpoint.replaceAll("<>","")}</strong><br> ${error }
                    <br>&lt;${IRI.replaceAll("([^a-zA-Z0-9])","$1&#8203;")}&gt;
                </p>
            </c:when>
            <c:when test="${statusCode =='406'}">
                <p>
                    <sp:message code='error.somethingWrong' text='something went wrong'/> <br> <strong> <sp:message
                        code='error.unacceptable' text='you requested an unacceptable content'/></strong><br>
                </p>
            </c:when>
            <c:otherwise>
                <p>
                    <sp:message code='error.somethingWrong' text='something went wrong'/><br>
                    <strong>${endpoint.replaceAll("<>","")}</strong> <br> doesn't contain any information about <br>
                    <strong>&lt;${IRI.replaceAll("([^a-zA-Z0-9])","$1&#8203;")}&gt;</strong>
                </p>
            </c:otherwise>
        </c:choose>
    </div>
</article>
<jsp:include page="inc/schema_footer.jsp"></jsp:include>

<script>

    $('#logo').click(function () {
        document.location = '${conf.getHomeUrl()}';
    });</script>
</body>
