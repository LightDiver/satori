package main.lightdiver.skim.model;

import org.primefaces.event.SelectEvent;
import org.primefaces.model.mindmap.DefaultMindmapNode;
import org.primefaces.model.mindmap.MindmapNode;

import javax.enterprise.context.SessionScoped;
import javax.faces.bean.ManagedBean;
import java.io.Serializable;

/**
 * Created by Serj on 11.11.2015.
 */
@ManagedBean
@SessionScoped
public class ToolsBean implements Serializable{
    private MindmapNode mapSite;



    public ToolsBean() {
        mapSite = new DefaultMindmapNode("satori.com", "Satori", "FFCC00", false);

        MindmapNode userm = new DefaultMindmapNode("User Menu", "User Menu", "6f9ebe", true);
        mapSite.addNode(userm);
        MindmapNode userlin = new DefaultMindmapNode("Login", "User Login", "6e9ebf", true);
        MindmapNode userlut = new DefaultMindmapNode("Logout", "User Logout", "6e9ebf", true);
        MindmapNode userreg = new DefaultMindmapNode("Register", "User Register", "6e9ebf", true);
        userm.addNode(userlin);
        userm.addNode(userlut);
        userm.addNode(userreg);

        MindmapNode contacts = new DefaultMindmapNode("Contacts", "Contacts", "6f9ebe", true);
        mapSite.addNode(contacts);
    }
    public MindmapNode getMapSite() {
        return mapSite;
    }
    public void onNodeSelect(SelectEvent event) {
        MindmapNode node = (MindmapNode) event.getObject();
        //load children of select node and add via node.addNode(childNode);
    }

}
