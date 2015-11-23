package main.lightdiver.skim.model;

import main.lightdiver.skim.LoadMenu;

import javax.annotation.PostConstruct;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.swing.tree.TreeNode;
import java.util.List;

/**
 * Created by Serj on 20.11.2015.
 */
@ManagedBean
@SessionScoped
public class MenuFooterBean {
    private List<TreeNode> rootNodes1;
    private List<TreeNode> rootNodes2;

    @PostConstruct
    public void initMenu(){
        rootNodes1 = LoadMenu.getFooterMenu1();
        rootNodes2 = LoadMenu.getFooterMenu2();
    }

    public List<TreeNode> getRootNodes1() {
        return rootNodes1;
    }

    public void setRootNodes1(List<TreeNode> rootNodes1) {
        this.rootNodes1 = rootNodes1;
    }

    public List<TreeNode> getRootNodes2() {
        return rootNodes2;
    }

    public void setRootNodes2(List<TreeNode> rootNodes2) {
        this.rootNodes2 = rootNodes2;
    }


    }
