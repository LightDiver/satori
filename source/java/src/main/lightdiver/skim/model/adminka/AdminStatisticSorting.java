package main.lightdiver.skim.model.adminka;

import org.richfaces.component.SortOrder;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.Serializable;

/**
 * Created by Serj on 11.12.2015.
 */
@ManagedBean
@ViewScoped
public class AdminStatisticSorting implements Serializable{

    private SortOrder actionStateOrder = SortOrder.unsorted;

    public void sortByActionState() {
        if (actionStateOrder.equals(SortOrder.unsorted)) {
            setActionStateOrder(SortOrder.descending);
        } else
            if(actionStateOrder.equals(SortOrder.descending)) {
            setActionStateOrder(SortOrder.ascending);
            }
            else{
                setActionStateOrder(SortOrder.unsorted);
            }
    }

    public SortOrder getActionStateOrder() {
        return actionStateOrder;
    }

    public void setActionStateOrder(SortOrder actionStateOrder) {
        this.actionStateOrder = actionStateOrder;
    }

}
