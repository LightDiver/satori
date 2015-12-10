package main.lightdiver.skim.model;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.swing.tree.TreeNode;
import java.util.List;

/**
 * Created by Serj on 20.11.2015.
 */
@ManagedBean
@SessionScoped
public class MenuBean {
    LocalizationBean localizationBean = (LocalizationBean) FacesContext.getCurrentInstance().getExternalContext().getSessionMap().get("localizationBean");
    private List<TreeNode> rootNodes1;
    private List<TreeNode> rootNodes2;

    public List<TreeNode> getRootNodes1() {
        return localizationBean.getLoadMenu().getFooterMenu1();
    }

    public void setRootNodes1(List<TreeNode> rootNodes1) {
        this.rootNodes1 = rootNodes1;
    }

    public List<TreeNode> getRootNodes2() {
        return localizationBean.getLoadMenu().getFooterMenu2();
    }

    public void setRootNodes2(List<TreeNode> rootNodes2) {
        this.rootNodes2 = rootNodes2;
    }


    }
