
function getElementsByXPath(xpath)
{
    var result = document.evaluate(xpath, document, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
    if( result != null )
    {
        var nodes = [];
        var node=result.iterateNext();
        while( node != null )
        {
            nodes.push(node);
            node = result.iterateNext();
        }
    }
    return nodes;
}

function replaceConditionKeyword(conditions)
{
    conditions = conditions.replace(/ and /i, " && ");
    conditions = conditions.replace(/ or /i, " || ");
    return conditions;
}

function kanban_image(model, field, id)
{
    if( eval("record."+field) == null )
    {
        // 如果小图没有换大图
        if( field == "image_small" )
        {
            return kanban_image(model, "image", id);
        }
        // 如果大图没有换小图
        if( field == "image" )
        {
            return kanban_image(model, "image_small", id);
        }
        return "";
    }
    
    var imageData = eval("record."+field+".raw_value");
    if( imageData.length == 0 )
    {
        return "";
    }
    return "data:image/png;base64,"+imageData;
}

function set_record_value()
{
    var nodes = getElementsByXPath("//templates//field");
    for( i in nodes )
    {
        var node = nodes[i];
        var fieldName = node.attributes["name"].value;
        var fieldValue = eval("record."+fieldName+".value");
        if( (node.attributes["widget"] != null) &&
           (node.attributes["widget"].value == "monetary") )
        {
            if( record.currency_id.value == "USD" )
            {
                fieldValue = "$ " + fieldValue;
            }
            if( record.currency_id.value == "CNY" )
            {
                fieldValue = fieldValue + " ¥";
            }
        }
        var element = document.createTextNode(fieldValue);
        node.insertBefore(element, node.childNodes[0]);
    }
    nodes = getElementsByXPath("//img[@t-att-src]");
    for( i in nodes )
    {
        var node = nodes[i];
        try {
            node.src = eval(node.attributes["t-att-src"].value);
        } catch(e) {}
    }
    nodes = getElementsByXPath("//*[@t-esc]");
    for( i in nodes )
    {
        var node = nodes[i];
        var fieldValue = eval(node.attributes["t-esc"].value);
        var element = document.createTextNode(fieldValue);
        node.insertBefore(element, node.childNodes[0]);
    }
    nodes = getElementsByXPath("//*[@t-if]");
    for( i in nodes )
    {
        var node = nodes[i];
        try {
            var visible = eval(replaceConditionKeyword(node.attributes["t-if"].value));
            if( !visible )
            {
                node.parentNode.removeChild(node);
            }
        } catch(e) {nslog("Error" + e);}
    }
}