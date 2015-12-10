package main.lightdiver.skim.entity;

import com.google.common.collect.Iterators;
import com.google.common.collect.Lists;

import javax.swing.tree.TreeNode;
import java.util.Enumeration;
import java.util.List;


/**
 * Created by Serj on 20.11.2015.
 */
public class TreeNodeMenu implements TreeNode {
    private String type;
    private String name;
    private List<TreeNode> children;
    private TreeNode parent = null;
    private String link;
    private boolean leaf;

    public TreeNodeMenu(String type, String name, String link, boolean leaf){
        this.type = type;
        this.name = name;
        this.leaf = leaf;
        this.link = link;
        if(!leaf) {
            this.children = Lists.newArrayList();
        }
    }



    public TreeNode getChildAt(int childIndex) {
        return this.isLeaf()?null: this.children.get(childIndex);
    }

    public int getChildCount() {
        return this.children.size();
    }

    public TreeNode getParent() {
        return this.parent;
    }

    public int getIndex(TreeNode node) {
        return children.indexOf(node);
    }

    public boolean getAllowsChildren() {
        return true;
    }

    public boolean isLeaf() {
        return this.leaf;
    }

    public Enumeration children() {
        return Iterators.asEnumeration(children.iterator());
    }

    public void addChild(TreeNodeMenu o) {
        this.children.add(o);
        o.setParent(this);
    }

    public String getType() {
        return this.type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setParent(TreeNode parent) {
        this.parent = parent;
    }

    public String getLink() {
        return link;
    }
}
